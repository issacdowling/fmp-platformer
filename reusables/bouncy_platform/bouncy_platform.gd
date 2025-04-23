@tool

extends Node3D

@onready var platform_holder: Node3D = $PlatformHolder

# This should be a scene where the root is an STMCachedInstance3D, with an AnimatableBody3D and Area3D as children.
# Both should have a CollisionShape3D as children, but the Area's should extend upwards so it detects the player standing on it,
# where the Body's should just be the size of the platform itself for collision.
# They'll all be removed upon explosion, since the collision is only needed until it explodes (or breaks).
@export var platform_scene: PackedScene = preload("res://reusables/bouncy_platform/platforms/bouncy_dev_platform.tscn")
@export var shake_on_bounce: bool = true
@export var jump_velocity: float = 10
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D

var platform: AnimatableBody3D
var platform_body: Area3D

func _ready() -> void:
	spawn_platform()

# Called when the node enters the scene tree for the first time.
func spawn_platform() -> void:
	platform = platform_scene.instantiate()
	add_child(platform)
	
	if platform is AnimatableBody3D:
		for platform_children in platform.get_children():
			if platform_children is Area3D:
				platform_body = platform_children
	
	platform_body.area_entered.connect(_area_entered_platform)
	
func bounce(area: Area3D) -> void:
	Input.start_joy_vibration(0, 0.5, 0.5, 0.1)
	(area.get_parent() as Player).velocity.y = jump_velocity
	(area.get_parent() as Player).air_time = 0
	if shake_on_bounce:
		translate(Vector3.UP * 0.2)
		await get_tree().create_timer(0.05).timeout
		translate(-Vector3.UP * 0.2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _area_entered_platform(area: Area3D) -> void:
	if area.is_in_group("player"):
		bounce(area)
		audio_stream_player_3d.play(0.1)
