extends Node

var current_settings: Dictionary = {}
var json: JSON = JSON.new()
const SETTINGS_FILE_PATH: String = "user://settings.json"
const PROJECT_OVERRIDE_PATH: String = "user://project_overrides.cfg"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await Menu.ready # Ensure all setting things are prepared before changing.
	
	# The generic Xbox controller I'm using to test things has broken buttons by default.
	# Used an Xbox Elite Series 2 SDL remap but with this controller's ID to fix it.
	# Upstream in future?
	Input.add_joy_mapping("03000000d62000000620000050010000,Xbox 360 Controller,a:b0,b:b1,x:b2,y:b3,back:b6,guide:b8,start:b7,leftstick:b9,rightstick:b10,leftshoulder:b4,rightshoulder:b5,dpup:h0.1,dpdown:h0.4,dpleft:h0.8,dpright:h0.2,leftx:a0,lefty:a1,rightx:a3,righty:a4,lefttrigger:a2,righttrigger:a5,crc:f003,platform:Linux,", true)
	
	Menu.setting_changed.connect(_change_setting)
	
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
				found_renderer = Menu.RENDERER_ADVANCED
			"mobile":
				found_renderer = Menu.RENDERER_BASIC
			"gl_compatibility":
				found_renderer = Menu.RENDERER_COMPATIBILITY
				
		current_settings = {
			Menu.GLOBAL_ILLUMINATION: true,
			Menu.GLOBAL_ILLUMINATION_HALF_RES: true,
			Menu.GLOBAL_ILLUMINATION_RAY_COUNT: Menu.RAY_COUNT_32,
			Menu.GLOBAL_ILLUMINATION_CASCADES: 4,
			Menu.SCALING_METHOD: Menu.SCALING_METHODS_FSR2,
			Menu.SCALING_AMOUNT: 0.75,
			Menu.RENDERER: found_renderer
		}
		
	for setting: String in current_settings.keys():
		# Emitting using another node's emitter rather than using this function directly because other nodes
		# need to be aware of these changes
		Menu.setting_changed.emit(setting, current_settings[setting])

# warnings-disable
func _change_setting(setting: String, value: Variant) -> void:
	current_settings[setting] = value
	var settings_file: FileAccess = FileAccess.open(SETTINGS_FILE_PATH, FileAccess.WRITE)
	settings_file.store_string(JSON.stringify(current_settings))
	settings_file.close()
	
	print(setting, " set to ", value)
	match setting:
		Menu.GLOBAL_ILLUMINATION:
			print("WorldEnvironment Node will handle this")
			if value == false:
				Menu.GlobalIlluminationHalfResToggle.disabled = true
				Menu.GlobalIlluminationRayCountDropdown.disabled = true
				Menu.GlobalIlluminationCascadesSlider.editable = true
			else:
				Menu.GlobalIlluminationHalfResToggle.disabled = false
				Menu.GlobalIlluminationRayCountDropdown.disabled = false
				Menu.GlobalIlluminationCascadesSlider.editable = false

		Menu.GLOBAL_ILLUMINATION_HALF_RES:
			RenderingServer.gi_set_use_half_resolution(value as bool)
		Menu.GLOBAL_ILLUMINATION_RAY_COUNT:
			match value:
				Menu.RAY_COUNT_4:
					RenderingServer.environment_set_sdfgi_ray_count(RenderingServer.ENV_SDFGI_RAY_COUNT_4)
				Menu.RAY_COUNT_8:
					RenderingServer.environment_set_sdfgi_ray_count(RenderingServer.ENV_SDFGI_RAY_COUNT_8)
				Menu.RAY_COUNT_16:
					RenderingServer.environment_set_sdfgi_ray_count(RenderingServer.ENV_SDFGI_RAY_COUNT_16)
				Menu.RAY_COUNT_32:
					RenderingServer.environment_set_sdfgi_ray_count(RenderingServer.ENV_SDFGI_RAY_COUNT_32)
				Menu.RAY_COUNT_64:
					RenderingServer.environment_set_sdfgi_ray_count(RenderingServer.ENV_SDFGI_RAY_COUNT_64)
				Menu.RAY_COUNT_96:
					RenderingServer.environment_set_sdfgi_ray_count(RenderingServer.ENV_SDFGI_RAY_COUNT_96)
				Menu.RAY_COUNT_128:
					RenderingServer.environment_set_sdfgi_ray_count(RenderingServer.ENV_SDFGI_RAY_COUNT_128)
		Menu.GLOBAL_ILLUMINATION_CASCADES:
			print("WorldEnvironment Node will handle this")
		Menu.SCALING_METHOD:
			match value:
				Menu.SCALING_METHODS_FSR2:
					get_viewport().set_scaling_3d_mode(Viewport.SCALING_3D_MODE_FSR2)
				Menu.SCALING_METHODS_FSR1:
					get_viewport().set_scaling_3d_mode(Viewport.SCALING_3D_MODE_FSR)
				Menu.SCALING_METHODS_BILINEAR:
					get_viewport().set_scaling_3d_mode(Viewport.SCALING_3D_MODE_BILINEAR)
		Menu.SCALING_AMOUNT:
			get_viewport().set_scaling_3d_scale(value as float)
		Menu.RENDERER:
			var config_override: ConfigFile = ConfigFile.new()
			if value != Menu.RENDERER_ADVANCED:
				# If the renderer doesn't support these features, but they're on, alert the user and disable them.
				if (current_settings[Menu.GLOBAL_ILLUMINATION] == true || current_settings[Menu.SCALING_METHOD] != Menu.SCALING_METHODS_BILINEAR):
					Toast.make_timed_toast("Non-advanced renderers don't support FSR or Global Illumination.", 7)
					Menu.setting_changed.emit(Menu.SCALING_METHOD, Menu.SCALING_METHODS_BILINEAR)
					Menu.setting_changed.emit(Menu.GLOBAL_ILLUMINATION, false)				
				
				Menu.GlobalIlluminationToggle.disabled = true
				Menu.GlobalIlluminationHalfResToggle.disabled = true
				Menu.GlobalIlluminationRayCountDropdown.disabled = true
				Menu.GlobalIlluminationCascadesSlider.editable = true
				Menu.ScalingOptionsDropdown.disabled = true
			else:
				Menu.GlobalIlluminationToggle.disabled = false
				Menu.GlobalIlluminationHalfResToggle.disabled = false
				Menu.GlobalIlluminationRayCountDropdown.disabled = false
				Menu.GlobalIlluminationCascadesSlider.editable = false
				Menu.ScalingOptionsDropdown.disabled = false
				
			config_override.load(PROJECT_OVERRIDE_PATH)

			var selected_renderer: String = "gl_compatibility" # If somehow this fails, fall back on the most basic option.
			match value:
				Menu.RENDERER_ADVANCED:
					selected_renderer = "forward_plus"
				Menu.RENDERER_BASIC:
					selected_renderer = "mobile"
				Menu.RENDERER_COMPATIBILITY:
					selected_renderer = "gl_compatibility"
			# Need both, since mobile will be applied if on mobile, and regular on desktop
			config_override.set_value("rendering", "renderer/rendering_method.mobile", selected_renderer)
			config_override.set_value("rendering", "renderer/rendering_method", selected_renderer)
			
			config_override.save(PROJECT_OVERRIDE_PATH)
			
	# Although changing these through the UI makes the UI match the settings,
	# changes done otherwise do not affect the UI by default, so I make sure they do.
	match setting:
		Menu.GLOBAL_ILLUMINATION:
			Menu.GlobalIlluminationToggle.button_pressed = current_settings[setting] as bool
			Menu.GlobalIlluminationCascadesSlider.editable = current_settings[setting] as bool
			
		Menu.GLOBAL_ILLUMINATION_HALF_RES:
			Menu.GlobalIlluminationHalfResToggle.button_pressed = current_settings[setting] as bool
			
		Menu.GLOBAL_ILLUMINATION_RAY_COUNT:
			for index in range(Menu.GlobalIlluminationRayCountDropdown.item_count):
				if Menu.GlobalIlluminationRayCountDropdown.get_item_text(index) == current_settings[setting]:
					Menu.GlobalIlluminationRayCountDropdown.select(index)
				
			
		Menu.GLOBAL_ILLUMINATION_CASCADES:
			Menu.GlobalIlluminationCascadesSlider.value = current_settings[setting] as int
			
		Menu.SCALING_METHOD:
			for index in range(Menu.ScalingOptionsDropdown.item_count):
				if Menu.ScalingOptionsDropdown.get_item_text(index) == current_settings[setting]:
					Menu.ScalingOptionsDropdown.select(index)
			#Menu.ScalingOptionsDropdown.select(int(current_settings[setting])) #FIX ME LATER!!!
		Menu.SCALING_AMOUNT:
			Menu.ScalingAmountSlider.value = current_settings[setting] as float
		Menu.RENDERER:
			for index in range(Menu.RendererOptionsDropdown.item_count):
				if Menu.RendererOptionsDropdown.get_item_text(index) == current_settings[setting]:
					Menu.RendererOptionsDropdown.select(index)
	print(current_settings)

		
	
