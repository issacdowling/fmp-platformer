extends Sprite3D

@onready var welcome_area: Area3D = $Area3D

@onready var front_cam: PhantomCamera3D = $FrontEnemyCamera
@onready var rear_cam: PhantomCamera3D = $RearEnemyCamera
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var player: Player = %Player
@onready var switch: Node3D = $"../switch"

var done_once: bool = false
var shield_destination_pos: Vector3

func _ready() -> void:
	welcome_area.area_entered.connect(_player_entered)
	set_process(false)

func _player_entered(area: Area3D) -> void:
	if area.is_in_group("player") and !done_once:
		print(1)
		done_once = true
		audio_stream_player_3d.play()
		Menu.show_captive_dialogue("These are turrets.")
		front_cam.set_priority(100)
		await Menu.dialogue_interact
		audio_stream_player_3d.play()
		Menu.show_captive_dialogue("They shoot energy balls. They hurt.")
		await Menu.dialogue_interact
		audio_stream_player_3d.play()
		Menu.show_captive_dialogue("But you can destroy them, or even hit them right back! (Keyboard: F, Controller: X/Square)")
		await Menu.dialogue_interact
		audio_stream_player_3d.play()
		front_cam.set_priority(-1)
		rear_cam.set_priority(100)
		Menu.show_captive_dialogue("And most turrets can't look backwards, so they're vulnerable to punches (and friendly fire!)")
		await Menu.dialogue_interact
		audio_stream_player_3d.play()
		rear_cam.set_priority(-1)
		Menu.show_captive_dialogue("Let's see if you can get past. Disable the shields with that switch (Keyboard: E, Controller: B/Circle).")
		await Menu.dialogue_interact
		Menu.finish_captive_dialogue()
		player.interact.connect(switch.switch)
		
