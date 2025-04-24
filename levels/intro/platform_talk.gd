extends Sprite3D

@onready var welcome_area: Area3D = $Area3D

@onready var bounce_cam: PhantomCamera3D = $BounceCamera
@onready var break_cam: PhantomCamera3D = $BreakingCamera
@onready var move_cam: PhantomCamera3D = $MovingCamera

var done_once: bool = false


func _ready() -> void:
	welcome_area.area_entered.connect(_player_entered)

func _player_entered(area: Area3D) -> void:
	if area.is_in_group("player") and !done_once:
		print(1)
		done_once = true
		Menu.show_captive_dialogue("Well done!")
		await Menu.dialogue_interact
		Menu.show_captive_dialogue("Now, you must face these [tornado] rickety [/tornado] platforms...")
		await Menu.dialogue_interact
		Menu.show_captive_dialogue("The bouncy ones...")
		bounce_cam.set_priority(100)
		await Menu.dialogue_interact
		Menu.show_captive_dialogue("The breaking ones...")
		bounce_cam.set_priority(-1)
		break_cam.set_priority(100)
		await Menu.dialogue_interact
		Menu.show_captive_dialogue("And the moving ones...")
		break_cam.set_priority(-1)
		move_cam.set_priority(100)
		await Menu.dialogue_interact
		move_cam.set_priority(-1)
		Menu.show_captive_dialogue("Good luck!")
		await Menu.dialogue_interact
		Menu.finish_captive_dialogue()
		
