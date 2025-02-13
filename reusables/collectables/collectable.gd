@tool
extends Node3D
class_name Collectable

# Dicts or exporting seems to make the first letter uppercase, so make sure it's that way anyway?????
@export var type: String = "Coin"
@export var value: int = 1
@export var degress_per_second: float = 10

@onready var collectable_area: Area3D = $CollectableArea

func _ready() -> void:
	collectable_area.area_entered.connect(_on_collected)
	
func _on_collected(area: Area3D) -> void:
	if area.is_in_group("player"):
		Collectables.report_collected(value, type)
		queue_free()

func _process(delta: float) -> void:
	rotate_y(degress_per_second * delta)
	
