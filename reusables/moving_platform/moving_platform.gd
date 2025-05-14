@tool # Want to show movement even in the editor

extends Node3D

@onready var start_marker: Node3D = $StartMarker
@onready var end_marker: Node3D = $EndMarker
@onready var platform_holder: Node3D = $PlatformHolder

@export var travel_seconds: float = 3

# This should be a scene where the root is an AnimatableBody3D, and it just has a mesh and collider.
@export var platform_scene: PackedScene = preload("res://reusables/moving_platform/platforms/moving_dev_platform.tscn")

var start_pos: Vector3
var end_pos: Vector3
var progress: float = 0

var platform: AnimatableBody3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_pos = start_marker.position
	end_pos = end_marker.position

	platform = platform_scene.instantiate()
	platform.sync_to_physics = false # Linus tech tip: This is necessary or any movement of the parent node breaks everything
	add_child(platform)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	progress += delta/travel_seconds
	if progress >= 1:
		if start_pos == start_marker.position:
			start_pos = end_marker.position
			end_pos = start_marker.position
		else:
			start_pos = start_marker.position
			end_pos = end_marker.position
		progress = 0

		
	platform.position = lerp(start_pos, end_pos, progress)
	
func _notification(what: int) -> void:
	if what == NOTIFICATION_EDITOR_PRE_SAVE:
		set_process(false)
		platform.position = start_pos
		progress = 0
	elif what == NOTIFICATION_EDITOR_POST_SAVE:
		set_process(true)
