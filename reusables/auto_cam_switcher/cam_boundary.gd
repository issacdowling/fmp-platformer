@tool

extends Node3D
class_name CamBoundary

@onready var area: Area3D = $Area
@onready var camera: PhantomCamera3D = $Camera
@export var original_priority: int = 0

@onready var switcher: AutoCamSwitcher = %AutoCamSwitcher
@onready var player: CharacterBody3D = %Player

var editor_bound_colour: Color = Color.RED
var editor_bound_opacity: float = 0.2

func _ready() -> void:
	# Show boundaries in editor so it's easy to tell where camera transitions are
	if (is_part_of_edited_scene() and switcher.debug_bounds_editor) or (not is_part_of_edited_scene() and switcher.debug_bounds_playmode):

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

		#You can't look through a camera when it's got a cube over it, so this should not appear during playmode.
		if (is_part_of_edited_scene() and switcher.debug_bounds_editor):
			var cam_debug_cube_meshinstance: MeshInstance3D = MeshInstance3D.new()
			cam_debug_cube_meshinstance.mesh = BoxMesh.new()
			(cam_debug_cube_meshinstance.mesh as BoxMesh).size = Vector3(0.5,0.5,0.5)
			var cam_debug_mat: StandardMaterial3D = StandardMaterial3D.new()
			cam_debug_mat.albedo_color = editor_bound_colour
			cam_debug_cube_meshinstance.material_override = cam_debug_mat
			camera.add_child(cam_debug_cube_meshinstance)


	# Adds itself to the list of known boundaries owned by the CamSwitcher in the scene,
	# prevents manual work.
	if not is_part_of_edited_scene():
		assert(camera.camera_3d_resource, "No Camera3DResource associated with: " + self.name + ". Troubles abound!")
		switcher.cam_boundaries.append(self)

	# If original_priority was untouched, but the camera's priority was touched,
	# we should make this script take a value from the camera. Otherwise, swap that.
	if original_priority == 0:
		original_priority = camera.priority
	else:
		camera.priority = original_priority
