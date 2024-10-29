extends Node

var current_settings: Dictionary = {}
var json: JSON = JSON.new()
const SETTINGS_FILE_PATH: String = "user://settings.json"
const PROJECT_OVERRIDE_PATH: String = "user://project_overrides.cfg"

@onready var GlobalIlluminationToggle: CheckButton = %GlobalIlluminationToggle
@onready var ScalingOptionsDropdown: OptionButton = %ScalingOptions
@onready var ScalingAmountSlider: HSlider = %ScalingAmount
@onready var RendererOptionsDropdown: OptionButton = %RendererOptions
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await Pause.ready # Ensure all setting things are prepared before changing.
	
	Pause.setting_changed.connect(_change_setting)
	
	if FileAccess.file_exists(SETTINGS_FILE_PATH):
		var settings_file: FileAccess = FileAccess.open(SETTINGS_FILE_PATH, FileAccess.READ)
		# Add some error checking here
		json.parse(settings_file.get_as_text())
		current_settings = json.data
		settings_file.close()
	else:
		var found_renderer: String = "gl_compatibility"
		match ProjectSettings.get_setting("renderer/rendering_method"):
			"forward_plus":
				found_renderer = Pause.RENDERER_ADVANCED
			"mobile":
				found_renderer = Pause.RENDERER_BASIC
			"gl_compatibility":
				found_renderer = Pause.RENDERER_COMPATIBILITY
				
		current_settings = {
			Pause.GLOBAL_ILLUMINATION: true,
			Pause.SCALING_METHOD: Pause.SCALING_METHODS_FSR2,
			Pause.SCALING_AMOUNT: 0.75,
			Pause.RENDERER: found_renderer
		}
		
	for setting: String in current_settings.keys():
		# Emitting using another node's emitter rather than using this function directly because other nodes
		# need to be aware of these changes
		Pause.setting_changed.emit(setting, current_settings[setting])

# warnings-disable
func _change_setting(setting: String, value: Variant) -> void:
	current_settings[setting] = value
	var settings_file: FileAccess = FileAccess.open(SETTINGS_FILE_PATH, FileAccess.WRITE)
	settings_file.store_string(JSON.stringify(current_settings))
	settings_file.close()
	
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
			get_viewport().set_scaling_3d_scale(value as float)
		Pause.RENDERER:
			var config_override: ConfigFile = ConfigFile.new()
			if value != Pause.RENDERER_ADVANCED:
				# If the renderer doesn't support these features, but they're on, alert the user and disable them.
				if (current_settings[Pause.GLOBAL_ILLUMINATION] == true || current_settings[Pause.SCALING_METHOD] != Pause.SCALING_METHODS_BILINEAR):
					Toast.make_timed_toast("Non-advanced renderers don't support FSR or Global Illumination.", 7)
					Pause.setting_changed.emit(Pause.SCALING_METHOD, Pause.SCALING_METHODS_BILINEAR)
					Pause.setting_changed.emit(Pause.GLOBAL_ILLUMINATION, false)				
				
				GlobalIlluminationToggle.disabled = true
				ScalingOptionsDropdown.disabled = true
			else:
				GlobalIlluminationToggle.disabled = false
				ScalingOptionsDropdown.disabled = false
				
			config_override.load(PROJECT_OVERRIDE_PATH)

			var selected_renderer: String = "gl_compatibility" # If somehow this fails, fall back on the most basic option.
			match value:
				Pause.RENDERER_ADVANCED:
					selected_renderer = "forward_plus"
				Pause.RENDERER_BASIC:
					selected_renderer = "mobile"
				Pause.RENDERER_COMPATIBILITY:
					selected_renderer = "gl_compatibility"
			# Need both, since mobile will be applied if on mobile, and regular on desktop
			config_override.set_value("rendering", "renderer/rendering_method.mobile", selected_renderer)
			config_override.set_value("rendering", "renderer/rendering_method", selected_renderer)
			
			config_override.save(PROJECT_OVERRIDE_PATH)
			
	# Although changing these through the UI makes the UI match the settings,
	# changes done otherwise do not affect the UI by default, so I make sure they do.
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
		Pause.RENDERER:
			for index in range(RendererOptionsDropdown.item_count):
				if RendererOptionsDropdown.get_item_text(index) == current_settings[setting]:
					RendererOptionsDropdown.select(index)
	print(current_settings)

		
	
