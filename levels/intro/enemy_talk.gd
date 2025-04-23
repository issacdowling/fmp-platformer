extends Sprite3D

@onready var welcome_area: Area3D = $Area3D

@onready var front_cam: PhantomCamera3D = $FrontEnemyCamera
@onready var rear_cam: PhantomCamera3D = $RearEnemyCamera
@onready var shields: Node3D = $"../Shields"

var done_once: bool = false
var shield_destination_pos: Vector3

func _ready() -> void:
	welcome_area.area_entered.connect(_player_entered)
	set_process(false)
	shield_destination_pos = shields.global_position - (Vector3.UP * 6)

func _player_entered(area: Area3D) -> void:
	if area.is_in_group("player") and !done_once:
		print(1)
		done_once = true
		Menu.show_captive_dialogue("These are turrets.")
		front_cam.set_priority(100)
		await Menu.dialogue_interact
		Menu.show_captive_dialogue("They shoot energy balls. They hurt.")
		await Menu.dialogue_interact
		Menu.show_captive_dialogue("But you can destroy them, or even hit them right back! (Keyboard: F, Controller: X/Square)")
		await Menu.dialogue_interact
		front_cam.set_priority(-1)
		rear_cam.set_priority(100)
		Menu.show_captive_dialogue("And most turrets can't look backwards, so they're vulnerable to punches (and friendly fire!)")
		await Menu.dialogue_interact
		rear_cam.set_priority(-1)
		Menu.show_captive_dialogue("Let's see if you can get past. Disabling shields.")
		await Menu.dialogue_interact
		Menu.finish_captive_dialogue()
		set_process(true)
		await get_tree().create_timer(4).timeout
		queue_free()
		
func _process(delta: float) -> void:
	shields.global_position = shields.global_position.lerp(shield_destination_pos, 0.3 * delta)
		
