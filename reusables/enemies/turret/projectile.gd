extends Node3D

@export var speed: float = 15
@onready var damage_area: Area3D = $DamageArea
@onready var shot_back_area: Area3D = $ShotBackArea
@onready var particle_emitter: GPUParticles3D = $GPUParticles3D
@onready var mesh: MeshInstance3D = $Mesh

var has_exploded: bool = false

# This is manually set by the turret, not to be initialised here (weird scene stuff)
# However, that also means I can't connect signals in _ready, so I do them with a setter
var player: Player: 
	set(value):
		player = value
		player.attack.connect(_on_hit)

var has_been_hit: bool = false
var expiration_counter: float = 4
const player_attack_distance: float = 2

func _ready() -> void:
	particle_emitter.visible = true
	particle_emitter.emitting = false
	damage_area.area_entered.connect(_on_damage_collision)
	damage_area.body_entered.connect(_on_obstacle_collision)

func _on_obstacle_collision(body: Node3D) -> void:
	if !body.is_in_group("player") and !body.is_in_group("enemy"):
		print("Projectile hit a wall")
		_explode()
	

# If the player hits the projectile broadly back in the direction of the turret, it should go straight back to it
# If not, it should still fly away
func _on_hit() -> void:
	if !has_been_hit and player.global_position.distance_to(self.global_position) < player_attack_distance:
		print("Player attacked projectile")
		has_been_hit = true
		if player.last_non_zero_move_vector.angle_to(global_transform.basis.z) <= deg_to_rad(25) and player.last_non_zero_move_vector.angle_to(global_transform.basis.z) >= deg_to_rad(-25):
			speed = -speed
		else:
			_explode()

func _process(delta: float) -> void:
	expiration_counter -= delta
	if expiration_counter <= 0:
		queue_free()
	translate(Vector3.FORWARD * delta * speed)

func _on_damage_collision(other_area: Area3D) -> void:
	if other_area.is_in_group("player") or other_area.is_in_group("enemy"):
		# Sometimes, when moving, multiple collisions happem, but we just need one
		damage_area.area_entered.disconnect(_on_damage_collision)
		print("Player/enemy hit by projectile")
		print(other_area.get_parent_node_3d().name)
		print(other_area.get_parent_node_3d().health.current_health)
		other_area.get_parent_node_3d().health.current_health -= 1 # This requires that any above groups must have health attributes
		particle_emitter.emitting = true
		# Free the mesh immediately, but only free the emitter once all of its particles are gone (and, since this is happening, set has_exploded to true so _explode can't cause crashes 
		mesh.queue_free()
		has_exploded = true
		
		set_process(false) # Stop the particle from moving
		await get_tree().create_timer(0.1).timeout
		particle_emitter.emitting = false
		
		await get_tree().create_timer(particle_emitter.lifetime).timeout
		queue_free()

func _explode() -> void:
	# We return early to prevent multiple _explode() calls from causing issues,
	if has_exploded:
		return
	
	has_exploded = true
	damage_area.area_entered.disconnect(_on_damage_collision)
	damage_area.body_entered.disconnect(_on_obstacle_collision)
	particle_emitter.emitting = true
	# Free the mesh immediately, but only free the emitter once all of its particles are gone
	mesh.queue_free()
	set_process(false) # Stop the particle from moving
	await get_tree().create_timer(0.1).timeout
	particle_emitter.emitting = false
	
	await get_tree().create_timer(particle_emitter.lifetime).timeout
	queue_free()
