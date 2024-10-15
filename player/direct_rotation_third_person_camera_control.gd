extends Node

@export var LOOK_AT: Node3D
@export var PHANTOM_CAMERA: PhantomCamera3D

# Remember to make this script local to the scene that you bring it into, so you can set exported vars

# This LOOK_AT _replaces_ the Phantom Camera LOOK_AT!
# This is just for if you want the camera to follow the player's rotation.
# Just set the Phantom Camera to 3rd person follow, set it to follow the player, set reasonable offsets
# Then, in my custom node, set the look at, and MAKE SURE YOU DELETE ANY OTHER CAMERAS OR THIS MAY NOT APPLY

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	PHANTOM_CAMERA.set_third_person_rotation(LOOK_AT.rotation)
	pass
