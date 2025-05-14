extends Node3D

@onready var shields: Node3D = $"../Shields"
@onready var player: Player = %Player

var shield_destination_pos: Vector3

const switch_distance: float = 3

func _ready() -> void:
	set_process(false)
	shield_destination_pos = shields.global_position - (Vector3.UP * 5)
	#player.interact.connect(_switch) # this is now done by the helperguy script so you can't flip the switch while talking 

func switch() -> void:
	if player.global_position.distance_to(self.global_position) < switch_distance:
		rotate_y(deg_to_rad(180))
		set_process(true)
		await get_tree().create_timer(10).timeout
		set_process(false) 

func _process(delta: float) -> void:
		shields.global_position = shields.global_position.lerp(shield_destination_pos, 0.3 * delta)
