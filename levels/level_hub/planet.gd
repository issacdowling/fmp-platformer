@tool
extends Node3D
class_name Planet

@export var degrees_per_second: float = 5
@export var spinning: bool = true

@onready var level_container: Node3D = $Levels

@onready var front_text: MeshInstance3D = $PlanetTextFront
@onready var left_text: MeshInstance3D = $PlanetTextLeft
@onready var right_text: MeshInstance3D = $PlanetTextRight
@onready var back_text: MeshInstance3D = $PlanetTextBack

@export var world_number: int = 0
@export var world_name: String = "Example World"
@export var world_scene: PackedScene = preload("res://levels/Test/test_level_direct_rotation.tscn")

func _ready() -> void:
	# By default, level containers should be deactivated
	level_container.visible = false
	
	
	var text_mat: StandardMaterial3D = StandardMaterial3D.new()
	text_mat.albedo_color = Color.WHITE
	text_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	var text_mesh: TextMesh = TextMesh.new()
	text_mesh.text = world_name
	text_mesh.font_size = 120
	text_mesh.material = text_mat
	text_mesh.font = load("res://reusables/fonts/sora/Sora-Regular.otf")
	
	front_text.mesh = text_mesh
	left_text.mesh = text_mesh
	right_text.mesh = text_mesh
	back_text.mesh = text_mesh

func _process(delta: float) -> void:
	if spinning:
		self.rotate_y(deg_to_rad(degrees_per_second) * delta)
	else:
		self.rotation.y = lerp_angle(self.rotation.y, 0, 0.25)
