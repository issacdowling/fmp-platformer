extends Node

signal update(values: Dictionary[String, int])

var collected: Dictionary[String, int] = {"Coin": 0, "Corn": 0}
@export var popup_display_length_seconds: int = 3
@onready var display_timer: Timer = $CollectableDisplayTimer

# Ensure that the initial display is up-to-date
func _ready() -> void:
	update.emit(collected)
	display_timer.timeout.connect(_on_hud_done)

func report_collected(count: int, type: String) -> void:
	assert(collected.has(type), "unrecognised collectable")
	collected[type] += count


	update.emit(collected)
	print(type, " collected")
	Menu.show_collectables()
	display_timer.start(popup_display_length_seconds)

func _on_hud_done() -> void:
	Menu.hide_collectables()
