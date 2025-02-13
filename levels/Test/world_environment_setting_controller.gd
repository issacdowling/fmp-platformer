extends WorldEnvironment


# Init used here, since otherwise the signal is emitted before this Node is connected to it
func _init() -> void:
	Menu.setting_changed.connect(_setting_changed)

func _setting_changed(name: String, value: Variant) -> void:
	match name:
		Menu.GLOBAL_ILLUMINATION:
			self.environment.sdfgi_enabled = value as bool
		Menu.GLOBAL_ILLUMINATION_CASCADES:
			self.environment.sdfgi_cascades = value as int
