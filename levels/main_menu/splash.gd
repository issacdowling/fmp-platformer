extends Node

@onready var splash: Control = %Splash

func _process(delta: float) -> void:
	splash.modulate.a -= 0.3 * delta
	if splash.modulate.a < 0:
		queue_free()
