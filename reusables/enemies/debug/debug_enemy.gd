extends Node

@onready var health: HealthEntity = $HealthEntity
@onready var area: Area3D = $EnemyArea

func _ready() -> void:
	area.area_entered.connect(_on_collision)
	health.dead.connect(_died)
	
func _on_collision(other_area: Area3D) -> void:
	if other_area.is_in_group("player"):
		print("Test player hit")
		(%Player as Player).health.current_health -= 1

func _died() -> void:
	queue_free()
