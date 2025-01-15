extends CSGTorus3D

@onready var player: CharacterBody3D = %Player
var positions_list: Array[Vector3]
@export var x_min: float = -45
@export var x_max: float = 45
@export var y_min: float = -80
@export var y_max: float = 80
var rad_x_min: float = deg_to_rad(x_min)
var rad_x_max: float = deg_to_rad(x_max)
var rad_y_min: float = deg_to_rad(y_min)
var rad_y_max: float = deg_to_rad(y_max)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for x in range(100):
		positions_list.append(Vector3(0,0,0))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	positions_list.append(player.global_position)
	self.rotation.x = clamp(self.rotation.x, rad_x_min, rad_x_max)
	self.rotation.y = clamp(self.rotation.y, rad_y_min, rad_y_max)
	self.look_at(positions_list.pop_front())
	
	
