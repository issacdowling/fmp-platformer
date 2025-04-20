extends Control

@onready var text_label: RichTextLabel = $RichTextLabel
@onready var background: ColorRect = $ColorRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text_label.visible = false
	background.visible = false


func make_timed_toast(text: String, duration: float = 4) -> void:
	# If they try to make a new toast with the same value as the old one, just return
	if text_label.text == "[center]" + text + "[/center]":
		return
	animation_player.play("fade_in")
	text_label.text = "[center]" + text + "[/center]"
	text_label.visible = true
	background.visible = true
	await get_tree().create_timer(duration).timeout
	animation_player.play("fade_out")

func make_script_dismissable_toast(text: String) -> void:
	# If they try to make a new toast with the same value as the old one, just return
	if text_label.text == "[center]" + text + "[/center]":
		return
	animation_player.play("fade_in")
	text_label.text = "[center]" + text + "[/center]"
	text_label.visible = true
	background.visible = true
	
func dismiss_script_dismissable_toast() -> void:
	animation_player.play("fade_out")
	await animation_player.animation_finished
	text_label.text = ""
