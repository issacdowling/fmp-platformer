extends Node3D

@onready var player: Player = %Player

var target_angle: int = 0
var section_length: int = 40

func _ready() -> void:
	Menu.rotate_timer_done.connect(_spin)
	self.rotation.z = 0
	Menu.do_rotate_timer(section_length)
	print("test")

func _spin() -> void:
	target_angle += 90
	Menu.do_rotate_timer(section_length)
	return


# Slight rotation to further explain to the player what's going to happen
func _process(delta: float) -> void:
	#rotate_z(deg_to_rad(0.1 * delta))
	self.rotation.z = lerp_angle(self.rotation.z, deg_to_rad(target_angle), 3 * delta)
