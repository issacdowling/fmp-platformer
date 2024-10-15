extends Control

@onready var text_label = $RichTextLabel
@onready var background = $ColorRect
@onready var animation_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text_label.visible = false
	background.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func make_timed_toast(text: String, duration: float = 4):
	animation_player.play("fade_in")
	text_label.text = "[center]" + text + "[/center]"
	text_label.visible = true
	background.visible = true
	await get_tree().create_timer(duration).timeout
	animation_player.play("fade_out")
