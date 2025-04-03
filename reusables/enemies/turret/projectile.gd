extends Node3D

@export var speed: float = 15
@onready var damage_area: Area3D = $DamageArea
@onready var particle_emitter: GPUParticles3D = $GPUParticles3D
@onready var mesh: MeshInstance3D = $Mesh
var player: Player

var expiration_counter: float = 10

func _ready() -> void:
	particle_emitter.emitting = false

func _process(delta: float) -> void:
	expiration_counter -= delta
	if expiration_counter <= 0:
		queue_free()

	translate(Vector3.FORWARD * delta * speed)
	damage_area.area_entered.connect(_on_collision)

func _on_collision(other_area: Area3D) -> void:
	if other_area.is_in_group("player"):
		# Sometimes, when moving, multiple collisions happem, but we just need one
		damage_area.area_entered.disconnect(_on_collision)
		print("Bullet hit")
		player.health.current_health -= 1
		particle_emitter.emitting = true
		# Free the mesh immediately, but only free the emitter once all of its particles are gone
		mesh.queue_free()
		set_process(false) # Stop the particle from moving
		await get_tree().create_timer(0.1).timeout
		particle_emitter.emitting = false
		
		await get_tree().create_timer(particle_emitter.lifetime).timeout
		queue_free()
