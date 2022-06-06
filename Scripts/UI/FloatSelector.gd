extends Node2D

export var title = "Title"
export var starting_val = 1.0
var _value = starting_val

export var max_val = 2.0
export var min_val = 0.0
export var step = 0.1
export var button_index = 0
export var setting_name = ""
export var is_ui_selected = false
export var selected_scale = 1.2

signal pressed(_value)
	
func _process(delta):
	if(is_ui_selected and visible):
		if(Input.is_action_just_pressed("ui_left")):
			_on_DecreaseButton_pressed()
		if(Input.is_action_just_pressed("ui_right")):
			_on_IncreaseButton_pressed()

func _ready():
	$Title.text = title
	update_current_val(starting_val)

func _on_DecreaseButton_pressed():
	get_parent().select(button_index)
	if(min_val < _value - step):
		$ChangeAudio.play()
		update_current_val(_value - step)
	emit_signal("pressed", _value)

func _on_IncreaseButton_pressed():
	get_parent().select(button_index)
	if(max_val >= _value + step):
		$ChangeAudio.play()
		update_current_val(_value + step)
	emit_signal("pressed", _value)

func update_current_val(val):
	_value = val
	var ratio = (_value-min_val)/(max_val-min_val)
	$Value.text = str(Global.round_float(_value, 1))
	
func select():
	scale *= selected_scale
	$Light2D.visible = true
	is_ui_selected = true

func deselect():
	scale /= selected_scale
	$Light2D.visible = false
	is_ui_selected = false

func _on_Title_mouse_entered():
	get_parent().select(button_index)
