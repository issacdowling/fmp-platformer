extends Node3D

@onready var player: Player = %Player

func _ready() -> void:
	player.can_look = false
	await get_tree().create_timer(1).timeout
	Menu.fade_show_main()
