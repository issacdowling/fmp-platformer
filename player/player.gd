extends CharacterBody3D
class_name Player


@export var WALK_SPEED: float = 4.7
@export var SPRINT_MULTIPLIER: float = 1.5
@export var JUMP_VELOCITY: float = 7.5

@export var MOUSE_LOOK_SENSITIVITY: float = 0.05
@export var CONTROLLER_LOOK_SENSITIVITY: float = 2

@export var STEAL_MOUSE_ON_START: bool = true

# 40 because it's just less than 45, which is what you get if you hold W and A/D at once. 
# On keyboard, you should need to be specifically holding the direction of the wall.
@export var player_stick_wall_angle: float = 35

@onready var health: HealthEntity = $HealthEntity
@export var health_popup_display_length_seconds: float = 3
@onready var display_timer: Timer = $HealthEntity/Timer

@onready var fail_audio_player: AudioStreamPlayer3D = $FailAudioPlayer

var suggested_look_dir: Vector3
var last_non_zero_move_vector: Vector3

var air_time: float = 0
var current_walk_speed: float
var wall_time: float = 0

@onready var area: Area3D = $Area3D

var time_since_wall: float = 0

var sprinting: bool = false

var controls_allowed: bool = true

const show_health_seconds: float = 3

var can_look: bool = true

var currently_attacking: bool = false
signal attack
signal interact

func _ready() -> void:
	if STEAL_MOUSE_ON_START:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	health.update.connect(_on_health_update)
	Menu.set_health(health.current_health, health.peak_health)
	# Needed so the health bar doesn't stay open when respawning
	Menu.hide_health()
	display_timer.timeout.connect(_on_health_display_done)

func switch_scene(scene_file: String) -> void:
	# As begin_transition returns the length of the transition, we wait for that long before switching scene
	await get_tree().create_timer(Menu.begin_transition()).timeout 
	get_tree().change_scene_to_file(scene_file)
	Menu.exit_transition()
	
func switch_scene_packed(scene_file: PackedScene) -> void:
	# As begin_transition returns the length of the transition, we wait for that long before switching scene
	await get_tree().create_timer(Menu.begin_transition()).timeout 
	get_tree().change_scene_to_packed(scene_file)
	Menu.exit_transition()
	
# ONLY CALL THIS IF YOU'VE REQUESTED THE SCENE TO BE LOADED WITH RESOURCELOADER FIRST
func switch_scene_threaded(scene_file: String) -> void:
	# As begin_transition returns the length of the transition, we wait for that long before switching scene
	await get_tree().create_timer(Menu.begin_transition()).timeout 
	get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(scene_file))
	Menu.exit_transition()

func _physics_process(delta: float) -> void:
	move(delta)
	 
	if Input.is_action_just_pressed("interact"):
		interact.emit()

func move(delta: float) -> void:
	if Input.is_action_just_pressed("attack"):
		attack.emit()
		Input.start_joy_vibration(0, 0.2, 0.5, 0.1)
		# This is awkward, since blending doesn't happen as the other animations are based on the tree
		currently_attacking = true
		$AnimationTree.active = false
		$AnimationPlayer.play("punch1", 0.1)
		await $AnimationPlayer.animation_finished
		$AnimationTree.active = true
		currently_attacking = false
		
	## Apply gravity when in the air
	if not is_on_floor():
		_do_gravity(delta)

	# For situations where controls are locked, allow dialogue
	if not controls_allowed:
		velocity.x = 0
		velocity.z = 0
		move_and_slide()
		return



	## clear jump time when on ground or wall
	if is_on_floor() or is_on_wall():
		air_time = 0

	# Floor jumping
	if not is_on_wall_only() and Input.is_action_pressed("jump") and (is_on_floor_only() or (air_time < 0.1)):
		jump()

	# Get input, and move by input vector multiplied by the current transform	
	var input_dir := Input.get_vector("left", "right", "forwards", "backwards")
	# Unlike the original example, I DO NOT want this normalised, as analogue inputs should be analogue-ly usable
	var move_vector := (transform.basis * Vector3(input_dir.x, 0, input_dir.y))
		
	# Make "forwards" the direction that the camera's facing
	move_vector = move_vector.rotated(Vector3.UP, get_viewport().get_camera_3d().rotation.y)

	if move_vector != Vector3.ZERO:
		last_non_zero_move_vector = move_vector
	if is_on_wall_only():
		wall_time += delta
		# You can jump no matter what, if you're only on a wall. Only regular movement is restricted
		# based on the time you've been there.
		if Input.is_action_just_pressed("jump"):
			# This makes it so you stick to walls opposite to ones that you jump off of.
			last_non_zero_move_vector = get_wall_normal()
			time_since_wall = 0.3
			velocity.y += JUMP_VELOCITY
			velocity += get_wall_normal() * 5 # Move in the opposite direction that the wall is facing
			wall_time = 0 
		# If we've been not been on the wall without jumping off for more than 1s, and the last direction we moved was towards the wall, and we aren't still moving up from a previous jump, we should stick. Else, slip down
		elif wall_time < 1 and not Input.is_action_pressed("jump") and last_non_zero_move_vector.angle_to(-get_wall_normal()) <= deg_to_rad(player_stick_wall_angle) and self.velocity.y < 0:
			# This accidentally happens to enable wall-running. Keep this in as an "it's a feature, not a bug" thing?
			velocity.y = (Vector3() + get_gravity()*2 * delta).y #Only affect the player's Y value, or it'll prevent them from moving off the wall without jumping
			#_do_gravity(delta)
		else:
			_do_gravity(delta)
	else:
		wall_time = 0
		if time_since_wall >= 0:
			time_since_wall -= delta
			
	# If the player just jumped off the wall, don't let them keep moving
	if time_since_wall > 0:
		move_and_slide()
		return
		
	if move_vector and time_since_wall <= 0.0:  #  and not is_on_wall_only()  (removed because it makes things better now, but I'm not sure if it broke anything
		# Make sure to set appropriate animations AND DISABLE THE OTHERS
		$AnimationTree.set("parameters/conditions/idle", false)
		if sprinting:
			current_walk_speed = WALK_SPEED * SPRINT_MULTIPLIER
			$AnimationTree.set("parameters/conditions/run", true)
			$AnimationTree.set("parameters/conditions/walk", false)
		else:
			current_walk_speed = WALK_SPEED
			$AnimationTree.set("parameters/conditions/walk", true)
			$AnimationTree.set("parameters/conditions/run", false)

		# Move
		velocity.z = move_vector.z * current_walk_speed
		velocity.x = move_vector.x * current_walk_speed

		# Look in direction of movement
		var lookdir: float = atan2(-velocity.x, -velocity.z)
		$Armature.rotation.y = lerp_angle($Armature.rotation.y, lookdir, 6 * delta)


	# Stop when not pressing move buttons and grounded (THIS was stopping my wall jumps!)
	elif not move_vector and (is_on_floor() or is_on_wall()): 
		#TODO: Add a slippiness variable that impacts how quickly you slow down.
		velocity.x = 0
		velocity.z = 0
		$AnimationTree.set("parameters/conditions/idle", true)
		$AnimationTree.set("parameters/conditions/walk", false)
		$AnimationTree.set("parameters/conditions/run", false)
		
	# Controller / Arrow key looking
	if can_look:
		var look_dir := Input.get_vector("look_left", "look_right", "look_up", "look_down")
		# Got input earlier, move by input vector multiplied by the current transform	
		# Unlike the original example, I DO NOT want this normalised, as analogue inputs should be analogue-ly usable
		var look_vector := (transform.basis * Vector3(input_dir.x, 0, input_dir.y))
		var pcam_rotation_degrees: Vector3
		pcam_rotation_degrees = pcam.get_third_person_rotation_degrees()
			
		pcam_rotation_degrees.x -= look_dir.y * CONTROLLER_LOOK_SENSITIVITY
		pcam_rotation_degrees.x = clampf(pcam_rotation_degrees.x, min_pitch, max_pitch)
		pcam_rotation_degrees.y -= look_dir.x * CONTROLLER_LOOK_SENSITIVITY
		pcam_rotation_degrees.y = wrapf(pcam_rotation_degrees.y, min_yaw, max_yaw)
		pcam.set_third_person_rotation_degrees(pcam_rotation_degrees)



	move_and_slide()

func _do_gravity(delta: float) -> void:
	air_time += delta / 1.5
	velocity += (get_gravity() * delta) + (get_gravity() * air_time * 0.25)

func jump() -> void:
	velocity.y = JUMP_VELOCITY

func _on_health_update(amount: int) -> void:
	Input.start_joy_vibration(0, 0.8, 1, 0.15)
	Menu.set_health(amount, health.peak_health)
	Menu.show_health()
	display_timer.start(health_popup_display_length_seconds)
	
	if amount == 0:
		health.update.disconnect(_on_health_update)
		fail_audio_player.play()
		controls_allowed = false
		$AnimationTree.active = false
		$AnimationPlayer.play("death", 0.1, 1.5)
		await get_tree().create_timer(1).timeout 
		switch_scene(get_tree().current_scene.scene_file_path)

func _on_health_display_done() -> void:
	display_timer.stop()

	# Health should always be showing if below 25%, but not if above
	if health.current_health / float(health.peak_health) <= 0.25:
		return
	Menu.hide_health()

# For now, this is just the example from https://phantom-camera.dev/follow-modes/third-person

var min_yaw: float = 0
var max_yaw: float = 360

var min_pitch: float = -89.9
var max_pitch: float = 50

@onready var pcam: PhantomCamera3D = $PhantomCamera3D

func _input(event: InputEvent) -> void:
	if Menu.is_in_menu() or !can_look or !controls_allowed:
		return

	# Trigger whenever the mouse moves.
	if event is InputEventMouseMotion:
		var pcam_rotation_degrees: Vector3
		# Assigns the current 3D rotation of the SpringArm3D node - to start off where it is in the editor.
		pcam_rotation_degrees = pcam.get_third_person_rotation_degrees()
		
		pcam_rotation_degrees.x -= event.relative.y * MOUSE_LOOK_SENSITIVITY
		pcam_rotation_degrees.x = clampf(pcam_rotation_degrees.x, min_pitch, max_pitch)
		pcam_rotation_degrees.y -= event.relative.x * MOUSE_LOOK_SENSITIVITY
		pcam_rotation_degrees.y = wrapf(pcam_rotation_degrees.y, min_yaw, max_yaw)
		pcam.set_third_person_rotation_degrees(pcam_rotation_degrees)
