extends Node3D

@onready var player: Player = %Player

func _ready() -> void:
	player.interact.connect(_spin)

func _spin() -> void:
	rotate_z(deg_to_rad(90))
