extends Node

signal update(values: Dictionary)

# This is a Dictionary[String, int], but json.parse doesn't like me and needs it to be a plain Dictionary
var collected: Dictionary = {"Coin": 0, "Corn": 0}
var json: JSON = JSON.new()
@export var popup_display_length_seconds: int = 3
@onready var display_timer: Timer = $CollectableDisplayTimer

const COLLECTABLES_FILE_PATH: String = "user://collectables.json"


# Ensure that the initial display is up-to-date
func _ready() -> void:
	# The collectables file is intiated to zeroes already, so we don't need an else statement
	if FileAccess.file_exists(COLLECTABLES_FILE_PATH):
		var collectables_file: FileAccess = FileAccess.open(COLLECTABLES_FILE_PATH, FileAccess.READ)
		# Add some error checking here
		json.parse(collectables_file.get_as_text())
		collected = json.data
		collectables_file.close()
	
	update.emit(collected)
	display_timer.timeout.connect(_on_hud_done)

func report_collected(count: int, type: String) -> void:
	assert(collected.has(type), "unrecognised collectable")
	collected[type] += count

	update.emit(collected)
	print(type, " collected")
	Menu.show_collectables()
	# Need to figure out a way to prevent multiple timeouts. .stop() is not an answer, tried.
	display_timer.start(popup_display_length_seconds)

func _on_hud_done() -> void:
	Menu.hide_collectables()
	# Only save when the HUD element goes away so we're not saving on each collection, which
	# could be problematic for slower drives, and put more wear on solid-state ones
	var settings_file: FileAccess = FileAccess.open(COLLECTABLES_FILE_PATH, FileAccess.WRITE)
	settings_file.store_string(JSON.stringify(collected))
	settings_file.close()
	print("Collected saved: ", collected)
