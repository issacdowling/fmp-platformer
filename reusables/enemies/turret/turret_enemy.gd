extends Node3D

@onready var player: CharacterBody3D = %Player
@onready var health: HealthEntity = $HealthEntity
var positions_list: Array[Vector3]
# This will be multiplied by physics ticks per second to allow changing
# the physics tick without breaking this.
@export var delay_seconds: float = 0.3
@export var x_min: float = -45
@export var x_max: float = 45
@export var y_min: float = -80
@export var y_max: float = 80
@export var locked_vertical_aim: bool = true 
var rad_x_min: float = deg_to_rad(x_min)
var rad_x_max: float = deg_to_rad(x_max)
var rad_y_min: float = deg_to_rad(y_min)
var rad_y_max: float = deg_to_rad(y_max)

const neck_head_vertical_offset: float = 0.45
const head_rotation_offset_deg: float = 4.6

@onready var turret_neck: Node3D = $body/Neck
@onready var turret_head: Node3D = $body/Neck/Head

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# If the enemy's follow is set to be delayed (for 0 just won't run), add empty positions to the start of the queue
	# so that the current position is always that number of physics ticks behind.
	for x in range(delay_seconds * Engine.physics_ticks_per_second):
		positions_list.append(Vector3(0,0,0))
	health.dead.connect(_died)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	positions_list.append(player.global_position)

	var current_pos: Vector3 = positions_list.pop_front()

	turret_neck.look_at(current_pos)
	turret_neck.rotation_degrees.x = 0
	turret_neck.rotation_degrees.z = 0
	
	# Ideally wouldn't be necessary because the model would be set up right, but this is faster
	turret_neck.rotate_y(deg_to_rad(-90))
	
	turret_neck.rotation.x = clamp(turret_neck.rotation.x, rad_x_min, rad_x_max)
	turret_neck.rotation.y = clamp(turret_neck.rotation.y, rad_y_min, rad_y_max)
	
	assert(locked_vertical_aim, "Vertical aim must be locked for now.")
	if !locked_vertical_aim:
		turret_head.look_at(current_pos, Vector3.LEFT)
		#turret_head.rotate_z(deg_to_rad(-90))
		#turret_head.rotation_degrees.x = 0
		turret_head.rotation_degrees.y = 0
		#turret_head.rotate_z(deg_to_rad(head_rotation_offset_deg))
		
	#else:
		#turret_neck.look_at(Vector3(current_pos.x, current_pos.y, current_pos.z))

func _died() -> void:
	print("Turret died")
	queue_free()
