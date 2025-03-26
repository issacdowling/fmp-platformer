@tool

extends Node3D
class_name Level

@export var level_number: int = 0
@export var level_name: String = "Example Level"
@export var level_scene: String = "res://levels/Test/test_level_direct_rotation.tscn"
@export var text_relative_pos: Vector3 = Vector3(0, 1.2, 0)
@export var font_size: int = 32

@onready var level_text: MeshInstance3D = $LevelText

func _ready() -> void:
	_generate_text()
	
func _generate_text() -> void:
	var text_mat: StandardMaterial3D = StandardMaterial3D.new()
	text_mat.albedo_color = Color.WHITE
	text_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	var text_mesh: TextMesh = TextMesh.new()
	text_mesh.text = level_name
	text_mesh.font_size = font_size
	text_mesh.material = text_mat
	text_mesh.font = load("res://reusables/fonts/sora/Sora-Regular.otf")
	
	level_text.mesh = text_mesh
	level_text.position = text_relative_pos
	
# Ensure text isn't being saved
func _notification(what: int) -> void:
	if what == NOTIFICATION_EDITOR_PRE_SAVE:
		level_text.mesh = null
	elif what == NOTIFICATION_EDITOR_POST_SAVE:
		_generate_text()
