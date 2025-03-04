extends Node

# Even for other resolutions, this is the size of the canvas
const DISPLAY_WIDTH: int = 1920

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

const HEALTHBAR_MARGIN_PX: float = 12.5
const HEALTHBAR_CHUNK_PX: float = 125 
const HEALTHBAR_RADIUS_PX: float = 20
const HEALTHBAR_HEIGHT_PX: float = 100
var HEALTHBAR_GOOD_COLOUR: Color = Color.from_rgba8(124, 255, 99, 255) # Light green
var  HEALTHBAR_MEH_COLOUR: Color = Color.from_rgba8(255, 220, 99, 255) # Light yellow/orange
var  HEALTHBAR_BAD_COLOUR: Color = Color.from_rgba8(255, 78, 62, 255) # Light red

signal setting_changed

signal dialogue_interact

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

@onready var collectables_hud_control: Control = %CollectablesHUD
@onready var collectables_animator: AnimationPlayer = %CollectablesAnimator
@onready var coin_Label: RichTextLabel = %CoinLabel
@onready var corn_Label: RichTextLabel = %CornLabel

@onready var health_hud_control: Control = %HealthHUD
@onready var health_background: Panel = %HealthBackground
@onready var health_bar: Panel = %HealthBar
@onready var health_animator: AnimationPlayer = %HealthAnimator

@onready var dialogue_control: Control = %Dialogue
@onready var dialogue_background: Panel = %DialogueBackground
@onready var dialogue_label: RichTextLabel = %DialogueLabel
@onready var dialogue_animator: AnimationPlayer = %DialogueAnimator

# This is not called on level scene changes, just the initial game load.
func _ready() -> void:
	dialogue_control.visible = false
	health_hud_control.visible = false
	collectables_hud_control.visible = false
	PauseControl.visible = false
	TransitionControl.visible = false
	main_menu_control.visible = false
	
	# Main menu grab focus for controller controls
	start_button.grab_focus()
	
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
	
	# Connect Collectables Signals
	Collectables.update.connect(_collectables_update)

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
	if PauseControl.visible:
		PauseControl.visible = false
	else:
		PauseControl.visible = true
		settings_settings_button.grab_focus()

func begin_transition() -> float:
	TransitionAnimator.play("RESET")
	TransitionControl.visible = true
	TransitionAnimator.play("in_slide_down")
	return TransitionAnimator.get_animation("in_slide_down").length

func exit_transition() -> void:
	TransitionAnimator.play("out_slide_up")
	await TransitionAnimator.animation_finished
	TransitionControl.visible = false

func show_main() -> void:
	main_menu_control.visible = true

func show_collectables() -> void:
	# Don't re-run if already visible
	if collectables_hud_control.visible:
		return
	collectables_animator.play("slide_in")
	collectables_hud_control.visible = true

func hide_collectables() -> void:
	# Don't re-run if already not visible
	if not collectables_hud_control.visible:
		return
	collectables_animator.play("slide_out")
	await collectables_animator.animation_finished
	collectables_hud_control.visible = false

func show_health() -> void:
	# Don't re-run if already visible
	if health_hud_control.visible:
		return
	health_animator.play("slide_in")
	health_hud_control.visible = true

func hide_health() -> void:
	# Don't re-run if already not visible
	if not health_hud_control.visible:
		return
	health_animator.play("slide_out")
	await health_animator.animation_finished
	health_hud_control.visible = false

func set_health(amount: int, total: int) -> void:
	var healthbar_style: StyleBoxFlat = StyleBoxFlat.new()
	if amount/float(total) <= 0.25:
		healthbar_style.bg_color = HEALTHBAR_BAD_COLOUR
	elif amount/float(total) <= 0.8:
		healthbar_style.bg_color = HEALTHBAR_MEH_COLOUR
	else:
		healthbar_style.bg_color = HEALTHBAR_GOOD_COLOUR
	# Since the health section itself is smaller, the radius must be related but less high
	healthbar_style.set_corner_radius_all(int(HEALTHBAR_RADIUS_PX * 0.5))
	health_bar.add_theme_stylebox_override("panel", healthbar_style)

	health_background.size.x = HEALTHBAR_CHUNK_PX * total
	health_background.size.y = HEALTHBAR_HEIGHT_PX

	health_background.position.x = DISPLAY_WIDTH/2.0 - health_background.size.x / 2.0

	health_bar.size.x = (health_background.size.x - HEALTHBAR_MARGIN_PX * 2) * amount/float(total)
	health_bar.size.y = health_background.size.y - HEALTHBAR_MARGIN_PX * 2

	health_bar.position.x = HEALTHBAR_MARGIN_PX
	health_bar.position.y = HEALTHBAR_MARGIN_PX

func is_in_menu() -> bool:
	if PauseControl.visible or main_menu_control.visible:
		return true
	return false

# Scripts using this should call show_captive_dialogue, then await the dialogue_interact signal, 
# before either calling show again for new text, or finish to make it go away 
func show_captive_dialogue(text: String) -> void:
	const dialogue_format: String = "[type] [wave amp=10.0 freq=10.0] %s [/wave] [/type]"
	if !dialogue_control.visible:
		dialogue_animator.play("slide_in")
		dialogue_control.visible = true
	
	# Set it to nothing first so it always re-types
	dialogue_label.text = ""
	dialogue_label.text = dialogue_format % text

func finish_captive_dialogue() -> void:
	dialogue_animator.play("slide_out")
	await dialogue_animator.animation_finished
	dialogue_control.visible = false

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

func _collectables_update(values: Dictionary) -> void:
	coin_Label.text = "[wave]%d[/wave]" % values["Coin"]
	corn_Label.text = "[wave]%d[/wave]" % values["Corn"]
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		dialogue_interact.emit()
