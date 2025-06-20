@tool

extends Node3D

@onready var platform_holder: Node3D = $PlatformHolder

@export var break_seconds: float = 1.5

# This should be a scene where the root is an STMCachedInstance3D, with an AnimatableBody3D and Area3D as children.
# Both should have a CollisionShape3D as children, but the Area's should extend upwards so it detects the player standing on it,
# where the Body's should just be the size of the platform itself for collision.
# They'll all be removed upon explosion, since the collision is only needed until it explodes (or breaks).
@export var platform_scene: PackedScene = preload("res://reusables/breaking_platform/platforms/breaking_dev_platform.tscn")

var start_pos: Vector3
var break_progress: float = 0
var about_to_break: bool = false
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D

const DESPAWN_SECONDS: float = 3

var platform: STMCachedInstance3D
var platform_body: Area3D

func _ready() -> void:
	start_pos = self.global_position
	spawn_platform()
	print(platform.global_position)
	print(platform_body.global_position)


# Called when the node enters the scene tree for the first time.
func spawn_platform() -> void:
	platform = platform_scene.instantiate()
	add_child(platform)
	
	for platform_child in platform.get_children():
		if platform_child is StaticBody3D:
			for child_children in platform_child.get_children():
				if child_children is Area3D:
					platform_body = child_children
					#platform_body.global_position = start_pos
	
	platform_body.area_entered.connect(_area_entered_platform)

func _process(delta: float) -> void:
	if about_to_break:
		break_progress += delta * 45

		platform.position = lerp(platform.position, platform.position + Vector3.UP * 0.03, (sin(break_progress)/2))

func _area_entered_platform(area: Area3D) -> void:
	if area.is_in_group("player") and !about_to_break:
		begin_failing()

# Blast sends chunks flying, non-blast just lets them fall
func explode(blast: bool) -> void:
	about_to_break = false
	# When exploding, remove all children to get rid of collisions. Functionally, though we see the shards, it
	# should actually just suddenly disappear.
	platform.smash_the_mesh()
	for platform_child: Node in platform.get_children():
		platform_child.free()
		
	if blast:
		 #Define a callback to apply an impulse to a rigid body chunk
		var explode_callback: Callable = func(rb: RigidBody3D, _from: Object) -> void:
			rb.apply_impulse(-rb.position.normalized() * Vector3(1, -1, 1) * 5.0)
		
		# Apply the callback to each chunk of the mesh
		platform.chunks_iterate(explode_callback)

	await get_tree().create_timer(DESPAWN_SECONDS).timeout
	
	platform.chunks_kill()
	platform.free()
	spawn_platform()
	
	
func begin_failing() -> void:
	about_to_break = true
	Input.start_joy_vibration(0, 0, 0.2, 0)
	await get_tree().create_timer(break_seconds).timeout
	Input.stop_joy_vibration(0)
	Input.start_joy_vibration(0, 1, 1, 0.1)
	audio_stream_player_3d.play()
	explode(false)
