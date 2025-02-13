@tool
extends Node3D
class_name CamBoundary

@export var debug_bounds_editor: bool = true
@export var debug_bounds_runtime: bool = false

@onready var area: Area3D = $Area

@onready var player: CharacterBody3D = %Player

var editor_bound_colour: Color = Color.RED
var editor_bound_opacity: float = 0.4

func _ready() -> void:
	# Show boundaries in editor so it's easy to tell where camera transitions are
	if (is_part_of_edited_scene() and debug_bounds_editor) or (not is_part_of_edited_scene() and debug_bounds_runtime):
		var editor_bound_area_collider: CollisionShape3D = area.get_child(0)
		var editor_bound_meshinstance: MeshInstance3D = MeshInstance3D.new()
		editor_bound_meshinstance.mesh = BoxMesh.new()
		(editor_bound_meshinstance.mesh as BoxMesh).size = (editor_bound_area_collider.shape as BoxShape3D).size
		var editor_bound_mat: StandardMaterial3D = StandardMaterial3D.new()
		editor_bound_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		editor_bound_colour.a = editor_bound_opacity
		editor_bound_mat.albedo_color = editor_bound_colour
		editor_bound_meshinstance.material_override = editor_bound_mat
		editor_bound_area_collider.add_child(editor_bound_meshinstance)
		editor_bound_meshinstance.global_position = editor_bound_area_collider.global_position
