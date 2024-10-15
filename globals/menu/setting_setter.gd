extends Node

var current_settings: Dictionary = {}
var json = JSON.new()
const SETTINGS_FILE_PATH: String = "user://settings.json"

@onready var GlobalIlluminationToggle: CheckButton = $"../GlobalIlluminationToggle"
@onready var ScalingOptionsDropdown: OptionButton = $"../ScalingOptions"
@onready var ScalingAmountSlider: HSlider = $"../ScalingAmount"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await Pause.ready # Ensure all setting things are prepared before changing.
	
	Pause.setting_changed.connect(_change_setting)
	
	if FileAccess.file_exists(SETTINGS_FILE_PATH):
		var settings_file = FileAccess.open(SETTINGS_FILE_PATH, FileAccess.READ)
		# Add some error checking here
		json.parse(settings_file.get_as_text())
		current_settings = json.data
		settings_file.close()
	else:
		current_settings = {
			Pause.GLOBAL_ILLUMINATION: true,
			Pause.SCALING_METHOD: Pause.SCALING_METHODS_FSR2,
			Pause.SCALING_AMOUNT: 0.75
		}
		
	for setting in current_settings.keys():
		# Emitting using another node's emitter rather than using this function directly because other nodes
		# need to be aware of these changes
		Pause.setting_changed.emit(setting, current_settings[setting])
		match setting:
			Pause.GLOBAL_ILLUMINATION:
				GlobalIlluminationToggle.button_pressed = bool(current_settings[setting])
			Pause.SCALING_METHOD:
				for index in range(ScalingOptionsDropdown.item_count):
					if ScalingOptionsDropdown.get_item_text(index) == current_settings[setting]:
						ScalingOptionsDropdown.select(index)
				#ScalingOptionsDropdown.select(int(current_settings[setting])) #FIX ME LATER!!!
			Pause.SCALING_AMOUNT:
				ScalingAmountSlider.value = float(current_settings[setting])

func _change_setting(setting: String, value):
	current_settings[setting] = value
	var settings_file = FileAccess.open(SETTINGS_FILE_PATH, FileAccess.WRITE)
	settings_file.store_string(JSON.stringify(current_settings))
	
	print(setting, " set to ", value)
	match setting:
		Pause.GLOBAL_ILLUMINATION:
			print("WorldEnvironment Node will handle this")
		Pause.SCALING_METHOD:
			match value:
				Pause.SCALING_METHODS_FSR2:
					get_viewport().set_scaling_3d_mode(Viewport.SCALING_3D_MODE_FSR2)
				Pause.SCALING_METHODS_FSR1:
					get_viewport().set_scaling_3d_mode(Viewport.SCALING_3D_MODE_FSR)
				Pause.SCALING_METHODS_BILINEAR:
					get_viewport().set_scaling_3d_mode(Viewport.SCALING_3D_MODE_BILINEAR)
		Pause.SCALING_AMOUNT:
			get_viewport().set_scaling_3d_scale(value)
			
	print(current_settings)

		
	
