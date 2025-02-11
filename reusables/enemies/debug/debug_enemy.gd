extends Node

@onready var area: Area3D = $EnemyArea

func _ready() -> void:
	area.area_entered.connect(_on_collision)
	
func _on_collision(area: Area3D) -> void:
	if area.is_in_group("player"):
		print("Test player hit")
		(%Player as Player).health.current_health -= 1
