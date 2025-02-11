extends Node
class_name HealthEntity

signal dead

@export var peak_health: int = 4
var current_health: int = peak_health:
	set(value):
		if value > peak_health:
			current_health = peak_health
		elif value <= 0:
			current_health = 0
			dead.emit()
		else:
			current_health = value
		print("I've been set to: ", current_health)
