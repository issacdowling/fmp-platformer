extends Node3D
class_name Spaceship

@onready var canExitArea: Area3D = $CanExitArea
@onready var player: Player = %Player
var canExit: bool = false
var hasBegunBackgroundLoading: bool = false
var backgroundLoadingHasFinished: bool = false
var exiting_disabled: bool = false

const levelHubPath: String = "res://levels/level_hub/level_hub.tscn"
func _ready() -> void:
	canExitArea.area_entered.connect(_player_nearby.bind(true))
	canExitArea.area_exited.connect(_player_nearby.bind(false))
	
func _player_nearby(area: Area3D, in_area: bool) -> void:
	# Only respond to the player's area, not other things (like projectiles)
	if !area.is_in_group("player") or exiting_disabled:
		return
		
	canExit = in_area
	if canExit:
		Toast.make_script_dismissable_toast("Press Interact to exit level")
		# Load the level hub if the player is nearby, so it's fast for them to 
		# switch back when they press the button
		if !hasBegunBackgroundLoading:
			ResourceLoader.load_threaded_request(levelHubPath)
			print("Background loading level hub due to reaching end of level")
			hasBegunBackgroundLoading = true
	else:
		Toast.dismiss_script_dismissable_toast()
	if !backgroundLoadingHasFinished:
		if ResourceLoader.load_threaded_get_status(levelHubPath) == ResourceLoader.THREAD_LOAD_LOADED:
			print("Background loading level hub complete")
			backgroundLoadingHasFinished = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if canExit:
			player.switch_scene_threaded(levelHubPath)
