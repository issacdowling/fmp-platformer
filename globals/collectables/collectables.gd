extends Node

signal update(values: Dictionary[String, int])

var collected: Dictionary[String, int] = {"Coin": 0, "Corn": 0}

# Ensure that the initial display is up-to-date
func _ready() -> void:
	update.emit(collected)

func report_collected(count: int, type: String) -> void:
	assert(collected.has(type), "unrecognised collectable")
	collected[type] += count


	update.emit(collected)
	print(type, " collected")
	Menu.show_collectables()
	await get_tree().create_timer(3).timeout
	Menu.hide_collectables()
