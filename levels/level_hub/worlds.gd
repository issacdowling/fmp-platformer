extends Node3D

var target_world: int = 0
var total_worlds: int = 0

func _ready() -> void:
	for child in get_children():
		# If there are ever issues recognising worlds in the future, it'll be because of this
		if "world" in child.name.to_lower():
			total_worlds += 1

func _process(delta: float) -> void:
	self.position.x = lerp(self.position.x, -50.0*target_world, 0.1)

	if Input.is_action_just_pressed("look_left"):
		target_world -= 1
	elif Input.is_action_just_pressed("look_right"):
		target_world += 1

	# Wrap around
	if target_world < 0:
		target_world = total_worlds - 1
	elif target_world > total_worlds - 1:
		target_world = 0
