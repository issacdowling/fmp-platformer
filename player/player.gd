extends CharacterBody3D
class_name Player


@export var WALK_SPEED: float = 3.0
@export var SPRINT_MULTIPLIER: float = 1.6
@export var JUMP_VELOCITY: float = 7.5

@export var MOUSE_LOOK_SENSITIVITY: int = 1
@export var CONTROLLER_LOOK_SENSITIVITY: int = 1

@export var STEAL_MOUSE_ON_START: bool = true

@onready var health: HealthEntity = $HealthEntity

var air_time: float = 0
var current_walk_speed: float
var wall_time: float = 0
var time_since_wall: float = 0

func _ready() -> void:
	if STEAL_MOUSE_ON_START:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func switch_scene(scene_file: String) -> void:
	# As begin_transition returns the length of the transition, we wait for that long before switching scene
	await get_tree().create_timer(Menu.begin_transition()).timeout 
	get_tree().change_scene_to_file(scene_file)
	Menu.exit_transition()

func _physics_process(delta: float) -> void:
	move(delta)

func move(delta: float) -> void:
	
	# Just collectable menu test inputs for now
	if Input.is_action_just_pressed("look_down"):
		Menu.show_collectables()
	if Input.is_action_just_pressed("look_up"):
		Menu.hide_collectables()
		
	
	## Apply gravity when in the air
	if not is_on_floor():
		_do_gravity(delta)
	
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

	if move_vector and time_since_wall <= 0.0 and not is_on_wall_only():
		# Make sure to set appropriate animations AND DISABLE THE OTHERS
		$AnimationTree.set("parameters/conditions/idle", false)
		if Input.is_action_pressed("sprint"):
			current_walk_speed = WALK_SPEED * SPRINT_MULTIPLIER
			$AnimationTree.set("parameters/conditions/run", true)
			$AnimationTree.set("parameters/conditions/walk", false)
		else:
			current_walk_speed = WALK_SPEED
			$AnimationTree.set("parameters/conditions/walk", true)
			$AnimationTree.set("parameters/conditions/run", false)
			
		# Make "forwards" the direction that the camera's facing
		move_vector = move_vector.rotated(Vector3.UP, get_viewport().get_camera_3d().rotation.y)
		
		# Move
		velocity.z = move_vector.z * current_walk_speed
		velocity.x = move_vector.x * current_walk_speed

		# Look in direction of movement
		var lookdir: float = atan2(-velocity.x, -velocity.z)
		$Armature.rotation.y = lerp_angle($Armature.rotation.y, lookdir, 0.1)


	# Stop when not pressing move buttons and grounded (THIS was stopping my wall jumps!)
	elif not move_vector and (is_on_floor() or is_on_wall()): 
		#TODO: Add a slippiness variable that impacts how quickly you slow down.
		velocity.x = 0
		velocity.z = 0
		$AnimationTree.set("parameters/conditions/idle", true)
		$AnimationTree.set("parameters/conditions/walk", false)
		$AnimationTree.set("parameters/conditions/run", false)
		
	
	if is_on_wall_only():
		wall_time += delta
		
		# You can jump no matter what, if you're only on a wall. Only regular movement is restricted
		# based on the time you've been there.
		if Input.is_action_just_pressed("jump"):
			time_since_wall = 0.3
			velocity.y += JUMP_VELOCITY
			velocity += get_wall_normal() * 5 # Move in the opposite direction that the wall is facing
			wall_time = 0
		# If we've been on the wall without jumping off for more than 1s, we should lose grip and slip down
		elif wall_time < 1 and not Input.is_action_pressed("jump"):
			# This accidentally happens to enable wall-running. Keep this in as an "it's a feature, not a bug" thing?
			velocity.y = (Vector3() + get_gravity()*2 * delta).y #Only affect the player's Y value, or it'll prevent them from moving off the wall without jumping
			#_do_gravity(delta)
		else:
			_do_gravity(delta)
	else:
		wall_time = 0
		if time_since_wall >= 0:
			time_since_wall -= delta
		


	move_and_slide()
	
func _do_gravity(delta: float) -> void:
	air_time += delta / 1.5
	velocity += (get_gravity() * delta) + (get_gravity() * air_time * 0.25)
	
func jump() -> void:
	velocity.y = JUMP_VELOCITY
