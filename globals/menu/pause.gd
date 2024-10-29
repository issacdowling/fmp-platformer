extends Control

const GLOBAL_ILLUMINATION: String = "global_illumination"
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
@onready var ScalingOptionsDropdown: OptionButton = %ScalingOptions
@onready var ScalingAmountSlider: HSlider = %ScalingAmount
@onready var RendererOptionsDropdown: OptionButton = %RendererOptions

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	
	GlobalIlluminationToggle.toggled.connect(_on_global_illumination_toggle_toggled)
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if visible:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		if !visible:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		visible = !visible

func _on_global_illumination_toggle_toggled(toggled_on: bool) -> void:
	setting_changed.emit(GLOBAL_ILLUMINATION, toggled_on)

func _on_scaling_options_item_selected(index: int) -> void:
	setting_changed.emit(SCALING_METHOD, ScalingOptionsDropdown.get_item_text(index))

func _on_scaling_amount_value_changed(value: float) -> void:
	setting_changed.emit(SCALING_AMOUNT, value)
	
func _on_renderer_options_item_selected(index: int) -> void:
	setting_changed.emit(RENDERER, RendererOptionsDropdown.get_item_text(index))
