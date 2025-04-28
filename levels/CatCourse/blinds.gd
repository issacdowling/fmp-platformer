extends Node3D

# Although I could set the global position through code, that would mean manually editing it
# whenever I move the blinds. Becuase of this, I assume that they're down by default, and
# just set an offset for when it's time to move upwards.

var initial_position: Vector3
var end_position: Vector3
var up: bool = false
@onready var player: Player = %Player
@onready var top_switch: Node3D = $"../TopSwitch"
@onready var bottom_switch: Node3D = $"../BottomSwitch"
@export var open_movement_units: float = 9

func _ready() -> void:
	initial_position = self.global_position
	end_position = initial_position + Vector3.UP * open_movement_units
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and (player.global_position.distance_to(top_switch.global_position) < 3 or player.global_position.distance_to(bottom_switch.global_position) < 3):
		up = !up
		top_switch.rotate(Vector3.FORWARD, deg_to_rad(180)) # You can see it rotating, which is awkward
		bottom_switch.rotate(Vector3.FORWARD, deg_to_rad(180))
	if up:
		self.global_position = self.global_position.lerp(end_position, 0.4 * delta)
	else:
		self.global_position =  self.global_position.lerp(initial_position, 0.4 * delta)
