@tool
extends Node3D
class_name Collectable

# Dicts or exporting seems to make the first letter uppercase, so make sure it's that way anyway?????
@export var type: String = "Coin"
@export var value: int = 1
@export var degress_per_second: float = 2.5

@onready var collectable_area: Area3D = $CollectableArea
@onready var collectable_mesh: Node3D = $collectable_mesh
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D
var initial_rotation: Vector3

func _ready() -> void:
	initial_rotation = self.rotation
	collectable_area.area_entered.connect(_on_collected)
	
func _on_collected(area: Area3D) -> void:
	if area.is_in_group("player"):
		collectable_mesh.visible = false
		audio_stream_player_3d.play()
		Input.start_joy_vibration(0, 0.1, 0.2, 0.1)
		Collectables.report_collected(value, type)
		await audio_stream_player_3d.finished
		queue_free()

func _process(delta: float) -> void:
	collectable_mesh.rotate_y(degress_per_second * delta)

# Ensure @tool rotation previews aren't being saved
func _notification(what: int) -> void:
	if what == NOTIFICATION_EDITOR_PRE_SAVE:
		set_process(false)
		self.rotation = initial_rotation
	elif what == NOTIFICATION_EDITOR_POST_SAVE:
		set_process(true)
