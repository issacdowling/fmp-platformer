extends StaticBody3D

@export var player: CharacterBody3D
@export var activation_distance: float = 2


@onready var camera: PhantomCamera3D = $TestCam

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(player != null, "Player not attached to interactable: " + str(self.get_path()))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	if Input.is_action_just_pressed("interact"):
		if position.distance_to(player.position) < activation_distance:
			#%Player.switch_scene("res://levels/Test2/2test_level_direct_rotation.tscn")

			Toast.make_timed_toast("test", 4)

			if camera.priority == 0:
				camera.priority = 2
			else:
				camera.priority = 0
