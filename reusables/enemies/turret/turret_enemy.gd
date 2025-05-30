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

var fire_interval: float = randf_range(2,3)

@onready var turret_neck: Node3D = $body/Neck
@onready var turret_head: Node3D = $body/Neck/Head
@onready var project_hole: Node3D = $body/Neck/Head/ProjectHole
@onready var hit_area: Area3D = $HitArea
@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D
@onready var projectile: PackedScene = preload("res://reusables/enemies/turret/projectile.tscn")
@onready var body: Node3D = $body

var neck_initial_z: float 
var counter: float = 0
const player_attack_distance: float = 1.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# If the enemy's follow is set to be delayed (for 0 just won't run), add empty positions to the start of the queue
	# so that the current position is always that number of physics ticks behind.
	for x in range(delay_seconds * Engine.physics_ticks_per_second):
		positions_list.append(Vector3(0,0,0))
	health.dead.connect(_died)
	health.current_health = 1 # Don't set current health for health stuff using the editor, set it using code

	neck_initial_z = turret_neck.rotation.z
	
	player.attack.connect(_on_hit)
	
	gpu_particles_3d.emitting = false

func _on_hit() -> void:
	if player.global_position.distance_to(self.global_position) < player_attack_distance:
		_died()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	positions_list.append(player.global_position)

	var current_pos: Vector3 = positions_list.pop_front()

	turret_neck.look_at(current_pos)
	#turret_neck.rotation.y += deg_to_rad(1)
	turret_neck.rotation_degrees.x = 0
	turret_neck.rotation.z = neck_initial_z

	# Ideally wouldn't be necessary because the model would be set up right, but this is faster
	turret_neck.rotate_y(deg_to_rad(-90))

	turret_neck.rotation.x = clamp(turret_neck.rotation.x, rad_x_min, rad_x_max)
	turret_neck.rotation.y = clamp(turret_neck.rotation.y, rad_y_min, rad_y_max)
	
	assert(locked_vertical_aim, "Turret vertical aim must be locked for now.")

func _process(delta: float) -> void:
	counter += delta
	if counter > fire_interval and global_position.distance_to(player.global_position) < 50:
		counter = 0
		print("projecting")
		var projectile_instance: Node3D = projectile.instantiate()
		turret_head.add_child(projectile_instance)
		projectile_instance.top_level = true # We don't want it to follow the head movement
		projectile_instance.player = player # The projecticles can't get the player by %Player for some reason
		projectile_instance.global_position = project_hole.global_position
		projectile_instance.global_rotation = project_hole.global_rotation

func _died() -> void:
	body.visible = false
	set_process(false)
	
	gpu_particles_3d.emitting = true
	await get_tree().create_timer(0.1).timeout
	gpu_particles_3d.emitting = false
	await get_tree().create_timer(gpu_particles_3d.lifetime).timeout
	queue_free()
