@tool # Want to show movement even in the editor

extends Node3D

@onready var start_marker: Node3D = $StartMarker
@onready var end_marker: Node3D = $EndMarker
@onready var platform_holder: Node3D = $PlatformHolder

@export var travel_seconds: float = 3

# This should be a scene where the root is an AnimatableBody3D, and it just has a mesh and collider.
@export var platform_scene: PackedScene = preload("res://reusables/moving_platform/platforms/dev_platform.tscn")

var start_pos: Vector3
var end_pos: Vector3
var progress: float = 0

var platform: AnimatableBody3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_pos = start_marker.global_position
	end_pos = end_marker.global_position

	platform = platform_scene.instantiate()
	add_child(platform)
	
	# Shows the start and end positions
	#if Engine.is_editor_hint():
		#var editor_platform_node_start: AnimatableBody3D = platform_scene.instantiate()
		#start_marker.add_child(editor_platform_node_start)
		#
		#var editor_platform_node_end: AnimatableBody3D = platform_scene.instantiate()
		#end_marker.add_child(editor_platform_node_end)
		
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	progress += delta/travel_seconds
	if progress >= 1:
		if start_pos == start_marker.global_position:
			start_pos = end_marker.global_position
			end_pos = start_marker.global_position
		else:
			start_pos = start_marker.global_position
			end_pos = end_marker.global_position
		progress = 0

		
	platform.global_position = lerp(start_pos, end_pos, progress)
	##TODO: Smoothly move using physics force (or some other way that will bring character along)
	#if position == start_pos:
		#position = end_pos
	#else:
		#position = start_pos
