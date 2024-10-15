extends RigidBody3D

@export var start_pos: Vector3
@export var end_pos: Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#TODO: Smoothly move using physics force (or some other way that will bring character along)
	if position == start_pos:
		position = end_pos
	else:
		position = start_pos
