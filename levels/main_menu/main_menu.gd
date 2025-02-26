extends Node3D

@onready var player: Player = %Player

func _ready() -> void:
	player.can_look = false
	Menu.show_main()
