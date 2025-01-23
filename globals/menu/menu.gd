extends Node

const GLOBAL_ILLUMINATION: String = "global_illumination"
const GLOBAL_ILLUMINATION_CASCADES = "global_illumination_cascades"
const SCALING_METHOD: String = "scaling_method"
const SCALING_AMOUNT: String = "scaling_amount"
const RENDERER: String = "renderer"

const SCALING_METHODS_FSR2: String = "FSR 2"
const SCALING_METHODS_FSR1: String = "FSR 1"
const SCALING_METHODS_BILINEAR: String = "Bilinear"

const RENDERER_ADVANCED: String = "Advanced (Forward+)"
const RENDERER_BASIC: String = "Basic (Mobile)"
const RENDERER_COMPATIBILITY: String = "Compatibility (OpenGL)"

signal setting_changed

@onready var SettingSetter: Node = %SettingSetter

@onready var GlobalIlluminationToggle: CheckButton = %GlobalIlluminationToggle
@onready var GlobalIlluminationCascadesSlider: HSlider = %GlobalIlluminationCascades
@onready var ScalingOptionsDropdown: OptionButton = %ScalingOptions
@onready var ScalingAmountSlider: HSlider = %ScalingAmount
@onready var RendererOptionsDropdown: OptionButton = %RendererOptions

@onready var TransitionControl: Control = %Transitions
@onready var TransitionAnimator: AnimationPlayer = %TransitionAnimator

@onready var PauseControl: Control = %Pause
@onready var settings_quit_button: Button = %QuitFromSettingsBtn
@onready var settings_settings_button: Button = %SettingsFromSettingsBtn

@onready var main_menu_control: Control = %MainMenu
@onready var start_button: Button = %StartBtn
@onready var settings_button: Button = %SettingsBtn
@onready var quit_button: Button = %QuitBtn


# This is not called on level scene changes, just the initial game load.
func _ready() -> void:
	PauseControl.visible = false
	TransitionControl.visible = false
	main_menu_control.visible = true
	
	GlobalIlluminationToggle.toggled.connect(_on_global_illumination_toggle_toggled)
	GlobalIlluminationCascadesSlider.value_changed.connect(on_global_illumination_cascades_value_changed)
	ScalingOptionsDropdown.item_selected.connect(_on_scaling_options_item_selected)
	ScalingAmountSlider.value_changed.connect(_on_scaling_amount_value_changed)
	RendererOptionsDropdown.item_selected.connect(_on_renderer_options_item_selected)
	
	# Add all scaling options
	ScalingOptionsDropdown.add_item(SCALING_METHODS_FSR2)
	ScalingOptionsDropdown.add_item(SCALING_METHODS_FSR1)
	ScalingOptionsDropdown.add_item(SCALING_METHODS_BILINEAR)
	
	# Add all rendering options
	RendererOptionsDropdown.add_item(RENDERER_ADVANCED)
	RendererOptionsDropdown.add_item(RENDERER_BASIC)
	RendererOptionsDropdown.add_item(RENDERER_COMPATIBILITY)
	
	# Register main menu buttons
	start_button.pressed.connect(func() -> void: 
		await get_tree().create_timer(begin_transition()).timeout 
		get_tree().change_scene_to_file("res://levels/level_hub/level_hub.tscn")
		main_menu_control.visible = false
		exit_transition()
	)
	settings_button.pressed.connect(func() -> void: Menu.toggle_pause_menu())
	settings_settings_button.pressed.connect(func() -> void: Menu.toggle_pause_menu())
	quit_button.pressed.connect(func() -> void: get_tree().quit())
	settings_quit_button.pressed.connect(func() -> void: get_tree().quit())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		toggle_pause_menu()

# Includes logic to close and reopen the main menu where relevant
var pause_should_reopen_main: bool = false
func toggle_pause_menu() -> void:
	if PauseControl.visible:
		if pause_should_reopen_main:
			main_menu_control.visible = true
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if !PauseControl.visible:
		pause_should_reopen_main = main_menu_control.visible
		main_menu_control.visible = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	PauseControl.visible = !PauseControl.visible
	
func begin_transition() -> float:
	TransitionAnimator.play("RESET")
	TransitionControl.visible = true
	TransitionAnimator.play("in_slide_down")
	return TransitionAnimator.get_animation("in_slide_down").length
		
		
	
func exit_transition() -> void:
	TransitionAnimator.play("out_slide_up")
	await TransitionAnimator.animation_finished
	TransitionControl.visible = false

func _on_global_illumination_toggle_toggled(toggled_on: bool) -> void:
	setting_changed.emit(GLOBAL_ILLUMINATION, toggled_on)
	
func on_global_illumination_cascades_value_changed(value: int) -> void:
	setting_changed.emit(GLOBAL_ILLUMINATION_CASCADES, value)

func _on_scaling_options_item_selected(index: int) -> void:
	setting_changed.emit(SCALING_METHOD, ScalingOptionsDropdown.get_item_text(index))

func _on_scaling_amount_value_changed(value: float) -> void:
	setting_changed.emit(SCALING_AMOUNT, value)
	
func _on_renderer_options_item_selected(index: int) -> void:
	setting_changed.emit(RENDERER, RendererOptionsDropdown.get_item_text(index))
