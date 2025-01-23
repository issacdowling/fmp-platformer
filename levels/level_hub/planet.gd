@tool
extends Node3D
class_name Planet

@export var degrees_per_second: float = 5

@onready var front_text: MeshInstance3D = $PlanetTextFront
@onready var left_text: MeshInstance3D = $PlanetTextLeft
@onready var right_text: MeshInstance3D = $PlanetTextRight
@onready var back_text: MeshInstance3D = $PlanetTextBack
func _ready() -> void:
	var text_mat: StandardMaterial3D = StandardMaterial3D.new()
	text_mat.albedo_color = Color.WHITE
	text_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	var text_mesh: TextMesh = TextMesh.new()
	text_mesh.text = self.name
	text_mesh.font_size = 120
	text_mesh.material = text_mat
	text_mesh.font = load("res://reusables/fonts/sora/Sora-Regular.otf")
	
	front_text.mesh = text_mesh
	left_text.mesh = text_mesh
	right_text.mesh = text_mesh
	back_text.mesh = text_mesh

func _process(delta: float) -> void:
	self.rotate_y(deg_to_rad(degrees_per_second) * delta)
