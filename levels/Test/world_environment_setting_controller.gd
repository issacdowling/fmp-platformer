extends WorldEnvironment


# Init used here, since otherwise the signal is emitted before this Node is connected to it
func _init() -> void:
	Pause.setting_changed.connect(_setting_changed)

func _setting_changed(name: String, value: Variant) -> void:
	match name:
		Pause.GLOBAL_ILLUMINATION:
			self.environment.sdfgi_enabled = bool(value)
