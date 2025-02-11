extends Node3D

var planets: Dictionary[int, Planet]
var target_world: int = 0
var total_worlds: int = 0

@export var intergalactic_planetary: float = 60

func _ready() -> void:
	Toast.make_timed_toast("E / Square / X to select		</>/^ / Right stick to navigate", 10)
	for child in get_children():
		# If there are ever issues recognising worlds in the future, it'll be because of this
		if child is Planet:
			child.global_position = Vector3(intergalactic_planetary*child.world_number, 0, 0)
			assert(!planets.has(child.world_number), "Worlds should not share the same world number.")
			planets[child.world_number] = child
			total_worlds += 1
			child.selecting_levels.connect(_inhibit_level_controls)
			
		print("Total worlds: ", total_worlds)

func _process(delta: float) -> void:
	self.position.x = lerp(self.position.x, -intergalactic_planetary*target_world, 0.1)

	# Don't waste cycles handling movement logic in edit mode
	if is_part_of_edited_scene():
		return

	# These could be done with _input callbacks, but I wnat to be able to disable
	# them by disabling _process, so it's best to do them here.
	if Input.is_action_just_pressed("look_left"):
		target_world -= 1
	elif Input.is_action_just_pressed("look_right"):
		target_world += 1
	elif Input.is_action_pressed("interact"): 
		planets[target_world].spinning = !planets[target_world].spinning
		planets[target_world].levels_revealed = !planets[target_world].levels_revealed
		planets[target_world].revealed_timer = 0

	# Wrap around
	if target_world < 0:
		target_world = total_worlds - 1
	elif target_world > total_worlds - 1:
		target_world = 0

# The input from this is a signal that represents levels being selected, so if true,
# we want process to be false.
func _inhibit_level_controls(selecting: bool) -> void:
	set_process(!selecting)
