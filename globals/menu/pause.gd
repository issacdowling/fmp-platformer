extends Control

const GLOBAL_ILLUMINATION = "global_illumination"
const SCALING_METHOD = "scaling_method"
const SCALING_AMOUNT = "scaling_amount"

const SCALING_METHODS_FSR1 = "FSR 2"
const SCALING_METHODS_FSR2 = "FSR 1"
const SCALING_METHODS_BILINEAR = "Bilinear"

signal setting_changed

@onready var SettingSetter: Node = $SettingSetter

@onready var GlobalIlluminationToggle: CheckButton = $GlobalIlluminationToggle
@onready var ScalingOptionsDropdown: OptionButton = $ScalingOptions
@onready var ScalingAmountSlider: HSlider = $ScalingAmount

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	
	GlobalIlluminationToggle.toggled.connect(_on_global_illumination_toggle_toggled)
	ScalingOptionsDropdown.item_selected.connect(_on_scaling_options_item_selected)
	ScalingAmountSlider.value_changed.connect(_on_scaling_amount_value_changed)
	
	# Add all scaling options
	ScalingOptionsDropdown.add_item(SCALING_METHODS_FSR2)
	ScalingOptionsDropdown.add_item(SCALING_METHODS_FSR1)
	ScalingOptionsDropdown.add_item(SCALING_METHODS_BILINEAR)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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
