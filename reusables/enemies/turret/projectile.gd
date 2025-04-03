extends Node3D

@export var speed: float = 15
@onready var damage_area: Area3D = $DamageArea
@onready var shot_back_area: Area3D = $ShotBackArea
@onready var particle_emitter: GPUParticles3D = $GPUParticles3D
@onready var mesh: MeshInstance3D = $Mesh
var player: Player # This is manually set by the turret, not to be initialised here.
var has_been_hit: bool = false

var expiration_counter: float = 4

func _ready() -> void:
	particle_emitter.visible = true
	particle_emitter.emitting = false

func _process(delta: float) -> void:
	expiration_counter -= delta
	if expiration_counter <= 0:
		queue_free()

	translate(Vector3.FORWARD * delta * speed)
	damage_area.area_entered.connect(_on_damage_collision)
	shot_back_area.area_entered.connect(_on_attack_collision)
		
	# If the player hits the projectile broadly back in the direction of the turret, it should go straight back to it
	# If not, it should still fly away
	if !has_been_hit and player.currently_attacking and player.area in shot_back_area.get_overlapping_areas():
		print("Player attacked projectile")
		has_been_hit = true
		if player.last_non_zero_move_vector.angle_to(global_transform.basis.z) <= deg_to_rad(25) and player.last_non_zero_move_vector.angle_to(global_transform.basis.z) >= deg_to_rad(-25):
			speed = -speed
		else:
			damage_area.area_entered.disconnect(_on_damage_collision)
			particle_emitter.emitting = true
			# Free the mesh immediately, but only free the emitter once all of its particles are gone
			mesh.queue_free()
			set_process(false) # Stop the particle from moving
			await get_tree().create_timer(0.1).timeout
			particle_emitter.emitting = false
			
			await get_tree().create_timer(particle_emitter.lifetime).timeout
			queue_free()
	

func _on_damage_collision(other_area: Area3D) -> void:
	if other_area.is_in_group("player"):
		# Sometimes, when moving, multiple collisions happem, but we just need one
		damage_area.area_entered.disconnect(_on_damage_collision)
		print("Player hit by projectile")
		player.health.current_health -= 1
		particle_emitter.emitting = true
		# Free the mesh immediately, but only free the emitter once all of its particles are gone
		mesh.queue_free()
		set_process(false) # Stop the particle from moving
		await get_tree().create_timer(0.1).timeout
		particle_emitter.emitting = false
		
		await get_tree().create_timer(particle_emitter.lifetime).timeout
		queue_free()

func _on_attack_collision(other_area: Area3D) -> void:
	if other_area.is_in_group("player"):
		damage_area.area_entered.disconnect(_on_damage_collision)
