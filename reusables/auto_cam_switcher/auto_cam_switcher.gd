extends Node
class_name AutoCamSwitcher
# Make sure the switcher is marked as having a unique name!
# The boundaries need to be able to find it!

# Make sure all Pcameras have Camera3DResources

# Make sure any following / looking cameras are set to actually follow / look at player.

@onready var cam_boundaries: Array[CamBoundary]

@export var debug_bounds_editor: bool = true
@export var debug_bounds_playmode: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	# This is VERY silly, just waits to be sure that all camBounds have intialised
	await get_tree().create_timer(1).timeout
	for cam_boundary in cam_boundaries:
		cam_boundary.area.area_entered.connect(_handle_cambound_entry.bind(cam_boundary))



func _handle_cambound_entry(remote_area: Area3D, entered_boundary: CamBoundary) -> void:
	# When player enters a new boundary, set all other cameras back to their original priority,
	# then up the current boundary's camera's priority.
	if remote_area.is_in_group("player"):
		print("Player entered new CamBoundary: " + entered_boundary.name)
		for cam_boundary in cam_boundaries:
			cam_boundary.camera.priority = cam_boundary.original_priority
		entered_boundary.camera.priority = 100
