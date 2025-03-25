extends Node3D

# Although I could set the global position through code, that would mean manually editing it
# whenever I move the blinds. Becuase of this, I assume that they're down by default, and
# just set an offset for when it's time to move upwards.

var initial_position: Vector3
var end_position: Vector3
var up: bool = false
@onready var player: Player = %Player
@onready var switch: Node3D = $switch
@export var open_movement_units: float = 9

func _ready() -> void:
	initial_position = self.global_position
	end_position = initial_position + Vector3.UP * open_movement_units
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and player.global_position.distance_to(switch.global_position) < 3:
		up = !up
		switch.rotate(Vector3.UP, deg_to_rad(180)) # You can see it rotating, which is awkward
	if up:
		self.global_position = self.global_position.lerp(end_position, 0.01)
	else:
		self.global_position =  self.global_position.lerp(initial_position, 0.01)
