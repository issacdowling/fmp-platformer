extends StaticBody3D

@export var player: CharacterBody3D
@export var activation_distance: float = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(player != null, "Player not attached to interactable: " + str(self.get_path()))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		if position.distance_to(player.position) < activation_distance:
			Toast.make_timed_toast("test", 4)
