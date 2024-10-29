extends CharacterBody3D


@export var WALK_SPEED: float = 5.0
@export var JUMP_VELOCITY: float = 6.5

@export var MOUSE_LOOK_SENSITIVITY: int = 1
@export var CONTROLLER_LOOK_SENSITIVITY: int = 1

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	move(delta)

func move(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# Get input, and move by input vector multiplied by the current transform	
	var input_dir := Input.get_vector("left", "right", "forwards", "backwards")
	# Unlike the original example, I DO NOT want this normalised, as analogue inputs should be analogue-ly usable
	var move_vector := (transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	if move_vector:
		$AnimationTree.set("parameters/conditions/idle", false)
		$AnimationTree.set("parameters/conditions/walk", true)
		velocity.z = move_vector.z * WALK_SPEED
		velocity.x = move_vector.x * WALK_SPEED

		var lookdir: float = atan2(-velocity.x, -velocity.z)
		$Armature.rotation.y = lerp_angle($Armature.rotation.y, lookdir, 0.1)


	elif not move_vector and is_on_floor(): # Stop when not pressing move buttons and grounded (THIS was stopping my wall jumps!)
		#TODO: Add a slippiness variable that impacts how quickly you slow down.
		velocity.x = 0
		velocity.z = 0
		$AnimationTree.set("parameters/conditions/idle", true)
		$AnimationTree.set("parameters/conditions/walk", false)
		
	# Need to 
	if is_on_wall_only():
		if Input.is_action_just_pressed("jump"):
			velocity.y += JUMP_VELOCITY
			velocity.x += get_wall_normal().x * 5 # Move in the opposite direction that the wall is facing
		elif not Input.is_action_pressed("jump"):
			# This accidentally happens to enable wall-running. Keep this in as an "it's a feature, not a bug" thing?
			velocity.y = (Vector3() + get_gravity()*2 * delta).y #Only affect the player's Y value, or it'll prevent them from moving off the wall without jumping
			
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		jump()

	move_and_slide()
	
func jump() -> void:
	velocity.y += JUMP_VELOCITY
