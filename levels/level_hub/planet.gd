@tool
extends Node3D
class_name Planet

signal selecting_levels(selecting: bool)

@export var degrees_per_second: float = 5
@export var spinning: bool = true
var levels_revealed: bool = false:
	set(value):
		levels_revealed = value
		selecting_levels.emit(value)
		

@onready var level_container: Node3D = $Levels

@onready var front_text: MeshInstance3D = $PlanetTextFront
@onready var left_text: MeshInstance3D = $PlanetTextLeft
@onready var right_text: MeshInstance3D = $PlanetTextRight
@onready var back_text: MeshInstance3D = $PlanetTextBack

@onready var player: Player = %Player

const levels_relative_pos: Vector3 = Vector3(0, -5, 20)

@export var world_number: int = 0
@export var world_name: String = "Example World"

var levels: Dictionary[int, Level]
var total_levels: int = 0
var target_level: int = 0
var inter_level_distance: float = 4

var revealed_timer: float = 0


func _ready() -> void:
	# By default, level containers should be deactivated,
	# but only in-game. In the editor, we want to make them visible and properly positioned
	level_container.top_level = true
	if not is_part_of_edited_scene():
		levels_revealed = false
	else:
		levels_revealed = true
		
	for child in level_container.get_children():
		if child is Level:
			total_levels += 1
			child.position = Vector3(inter_level_distance*child.level_number, 0, 0)

			levels[child.level_number] = child

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

	# Wrap around
	if target_level < 0:
		target_level = total_levels - 1
	elif target_level > total_levels - 1:
		target_level = 0

	if levels_revealed:
		level_container.visible = true

		# Awkward workaround since global and relative positions act weirdly in edit mode,
		# needed so that levels are positioned correctly in edit mode.
		if is_part_of_edited_scene():
			level_container.global_position = self.global_position + levels_relative_pos
		else:
			level_container.position = lerp(level_container.position, levels_relative_pos + Vector3(-inter_level_distance*target_level,0,0), 0.25)

		# Input errors with these custom actions in editor, so avoid
		if is_part_of_edited_scene():
			return

		# Necessary to avoid instantly going into levels from pressing interact to enter the world.
		revealed_timer += delta
		if revealed_timer < 0.15:
			return

		if Input.is_action_just_pressed("look_left"):
			target_level -= 1
		elif Input.is_action_just_pressed("look_right"):
			target_level += 1
		elif Input.is_action_just_pressed("look_up"):
			target_level = 0
			spinning = true
			levels_revealed = false
		elif Input.is_action_just_pressed("interact"): 
			player.switch_scene(levels[target_level].level_scene.resource_path)
	else: 
		level_container.position = lerp(level_container.position, Vector3.ZERO, 0.25)
		if level_container.position.distance_to(Vector3.ZERO) < 1:
			level_container.visible = false
