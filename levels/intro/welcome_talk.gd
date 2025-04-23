extends Sprite3D

@onready var welcome_area: Area3D = $Area3D

@onready var gap_cam: PhantomCamera3D = $LittleGapCamera
@onready var bigger_gap_cam: PhantomCamera3D = $BigGapCamera
@onready var tower_cam: PhantomCamera3D = $TowerCamera

var done_once: bool = false


func _ready() -> void:
	welcome_area.area_entered.connect(_player_entered)

func _player_entered(area: Area3D) -> void:
	if area.is_in_group("player") and !done_once:
		print(1)
		done_once = true
		Menu.show_captive_dialogue("Welcome, brave astronaut!")
		await Menu.dialogue_interact
		Menu.show_captive_dialogue("You will have to complete this [tornado] treacherous [/tornado] obstacle course to gain your space license...")
		await Menu.dialogue_interact
		Menu.show_captive_dialogue("... fail, and you'll never fly a ship in your life :(")
		await Menu.dialogue_interact
		Menu.show_captive_dialogue("First, you'll cross the little gap")
		gap_cam.set_priority(100)
		await Menu.dialogue_interact
		Menu.show_captive_dialogue("Next, you'll cross this bigger gap")
		gap_cam.set_priority(-1)
		bigger_gap_cam.set_priority(100)
		await Menu.dialogue_interact
		Menu.show_captive_dialogue("Following that, you'll wall jump to the top of this tower")
		bigger_gap_cam.set_priority(-1)
		tower_cam.set_priority(100)
		await Menu.dialogue_interact
		tower_cam.set_priority(-1)
		Menu.show_captive_dialogue("... and so on. We'll get there when you're up there.")
		await Menu.dialogue_interact
		Menu.finish_captive_dialogue()
		
