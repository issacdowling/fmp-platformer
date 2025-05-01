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

const levels_relative_pos: Vector3 = Vector3(0, -4, 25)

@export var world_number: int = 0
@export var world_name: String = "Example World"

var levels: Dictionary[int, Level]
var total_levels: int = 0
var target_level: int = 0
var inter_level_distance: float = 4

var revealed_timer: float = 0

var initial_rotation: Vector3

var target_packed_up_to_date: bool = true
var target_packed_progress: float = 0

func _ready() -> void:
	initial_rotation = self.rotation
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
			assert(!levels.has(child.level_number), "Levels under a planet should not share level numbers.")
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
	if !target_packed_up_to_date and level_container.visible:
		print("Background loading new level: ", levels[target_level].level_scene)
		ResourceLoader.load_threaded_request(levels[target_level].level_scene)
		target_packed_up_to_date = true
		# If the load is instantly complete, it must be from cache, so the output should say as such
		if ResourceLoader.load_threaded_get_status(levels[target_level].level_scene) == ResourceLoader.THREAD_LOAD_LOADED:
			print("Background load (from cache) complete for: ", levels[target_level].level_scene)
			
	# If not instantly loaded from cache, update status when it changes, but don't waste space printing messages if not
	if ResourceLoader.load_threaded_get_status(levels[target_level].level_scene) != target_packed_progress:
		target_packed_progress = ResourceLoader.load_threaded_get_status(levels[target_level].level_scene)
		if target_packed_progress == ResourceLoader.THREAD_LOAD_LOADED:
			print("Background load complete for: ", levels[target_level].level_scene)
			
	if spinning:
		self.rotate_y(deg_to_rad(degrees_per_second) * delta)
	else:
		self.rotation.y = lerp_angle(self.rotation.y, 0, 0.25)

	if levels_revealed:
		# If the level container wasn't already visible, we should load the first scene before
		# any user interaction
		if !level_container.visible:
			target_packed_up_to_date = false
		level_container.visible = true

		# Awkward workaround since global and relative positions act weirdly in edit mode,
		# needed so that levels are positioned correctly in edit mode.
		if is_part_of_edited_scene():
			level_container.global_position = self.global_position + levels_relative_pos
		else:
			level_container.position = lerp(level_container.position, levels_relative_pos + Vector3(-inter_level_distance*target_level,0,0), min(15 * delta, 1))

		# Input errors with these custom actions in editor, so avoid
		if is_part_of_edited_scene():
			return

		# Necessary to avoid instantly going into levels from pressing interact to enter the world.
		revealed_timer += delta
		if revealed_timer < 0.15:
			return

		if Input.is_action_just_pressed("look_left"):
			target_level -= 1
			target_packed_up_to_date = false
		elif Input.is_action_just_pressed("look_right"):
			target_level += 1
			target_packed_up_to_date = false
		elif Input.is_action_just_pressed("look_up"):
			target_level = 0
			spinning = true
			levels_revealed = false
		elif Input.is_action_just_pressed("interact"): 
			player.can_look = true
			player.switch_scene_threaded(levels[target_level].level_scene)
			
			# Wrap around
		if target_level < 0:
			target_level = total_levels - 1
		elif target_level > total_levels - 1:
			target_level = 0
	else: 
		level_container.position = lerp(level_container.position, Vector3.ZERO, 15 * delta)
		if level_container.position.distance_to(Vector3.ZERO) < 1:
			level_container.visible = false
			
# Ensure @tool rotation previews aren't being saved
func _notification(what: int) -> void:
	if what == NOTIFICATION_EDITOR_PRE_SAVE:
		set_process(false)
		self.rotation = initial_rotation
	elif what == NOTIFICATION_EDITOR_POST_SAVE:
		set_process(true)
