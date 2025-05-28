extends Node3D

@onready var end_area: Area3D = %EndArea
@onready var start_area: Area3D = %StartArea
@onready var start_platform_cutout: Node3D = %BounceBackCutout
@onready var player: Player = %Player
@onready var spaceship: Spaceship = %Spaceship

var target_angle: int = 0
var section_length: int = 40
var safe: bool = false

func _ready() -> void:
	Menu.early_finish_rotate_timer(true)
	Menu.rotate_timer_done.connect(_failed)
	self.rotation.z = 0
	end_area.area_entered.connect(_entered_safe_zone)
	start_area.area_entered.connect(_about_to_start)
	start_area.area_exited.connect(_started)

	# Don't want the level ending early, reactivate when needed
	spaceship.exiting_disabled = true

func _about_to_start(_area: Area3D) -> void:
	if _area.is_in_group("player"):
		start_platform_cutout.visible = false

func _started(_area: Area3D) -> void:
	if _area.is_in_group("player"):
		Menu.do_rotate_timer(section_length)

		# We're on the last rotation, reactivate the spaceship exit
		if target_angle == 270:
			spaceship.exiting_disabled = false

func _failed() -> void:
	player.health.current_health = 0

func _entered_safe_zone(area: Area3D) -> void:
	if area.is_in_group("player"):
		safe = true
		Menu.early_finish_rotate_timer(false)
		target_angle += 90
		start_platform_cutout.visible = true

# Slight rotation to further explain to the player what's going to happen
func _process(delta: float) -> void:
	#rotate_z(deg_to_rad(0.1 * delta))
	if OS.has_feature("debug"):
		if Input.is_action_just_pressed("interact"):
			_entered_safe_zone(player.area)
	self.rotation.z = lerp_angle(self.rotation.z, deg_to_rad(target_angle), 3 * delta)
