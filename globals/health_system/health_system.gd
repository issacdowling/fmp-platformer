extends Node

var heal: int = 1

class HealthEntity:
	var peak_health: int = 4
	var current_health: int = peak_health:
		set(value):
			if current_health + value > peak_health:
				current_health = peak_health
			elif current_health + value <= 0:
				current_health = 0
			else:
				current_health = value
	func _init(peak_health: int) -> void:
		self.peak_health = peak_health
		self.current_health = peak_health

var entities: Dictionary[String, HealthEntity]

func add_to_entity_list(entity_name: String, peak_health: int) -> void:
	entities[entity_name] = HealthEntity.new(peak_health)

func hit(damage: int, entity: String) -> int:
	if entities[entity].current_health > 0:
		entities[entity].current_health = entities[entity].current_health - damage
	return entities[entity].current_health
	
func entity_heal(amount: int, entity: String) -> int:
	entities[entity].current_health += amount
	return entities[entity].current_health
