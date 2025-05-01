extends Node3D

@onready var player: CharacterBody3D = %Player
@onready var health: HealthEntity = $HealthEntity

@onready var turret_head: Node3D = $body/Neck/Head
@onready var project_hole: Node3D = $body/Neck/Head/ProjectHole
@onready var body: Node3D = $body
@onready var hit_area: Area3D = $HitArea
@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D
@onready var projectile: PackedScene = preload("res://reusables/enemies/turret/projectile.tscn")

var neck_initial_z: float 
var counter: float = 0
const player_attack_distance: float = 1.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health.dead.connect(_died)
	health.current_health = 1 # Don't set current health for health stuff using the editor, set it using code
	
	player.attack.connect(_on_hit)
	
	gpu_particles_3d.emitting = false

func _on_hit() -> void:
	if player.global_position.distance_to(self.global_position) < player_attack_distance:
		_died()

func _process(delta: float) -> void:
	counter += delta
	if counter > 2.5 and global_position.distance_to(player.global_position) < 50:
		counter = 0
		print("immobile projecting")
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
