extends Node3D

@onready var end_area: Area3D = %EndArea
@onready var start_area: Area3D = %StartArea
@onready var start_platform_cutout: Node3D = %BounceBackCutout
@onready var player: Player = %Player

var target_angle: int = 0
var section_length: int = 40
var safe: bool = false

func _ready() -> void:
	Menu.rotate_timer_done.connect(_spin)
	self.rotation.z = 0
	Menu.do_rotate_timer(section_length)
	end_area.area_entered.connect(_entered_safe_zone)
	start_area.area_entered.connect(_about_to_start)
	start_area.area_exited.connect(_started)

func _about_to_start(_area: Area3D) -> void:
	safe = false
	start_platform_cutout.visible = false

func _started(_area: Area3D) -> void:
	Menu.do_rotate_timer(section_length)

func _spin() -> void:
	if !safe:
		player.health.current_health = 0
	else:
		target_angle += 90
		start_platform_cutout.visible = true
	return

func _entered_safe_zone(area: Area3D) -> void:
	if area.is_in_group("player"):
		safe = true
		Menu.early_finish_rotate_timer()
	
# Slight rotation to further explain to the player what's going to happen
func _process(delta: float) -> void:
	#rotate_z(deg_to_rad(0.1 * delta))
	if OS.has_feature("debug"):
		if Input.is_action_just_pressed("interact"):
			_spin()
	self.rotation.z = lerp_angle(self.rotation.z, deg_to_rad(target_angle), 3 * delta)
