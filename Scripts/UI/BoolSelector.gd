extends Node2D

export var title = "Title"
export var is_selected = false
var current_val
export var button_index = 0

export var is_ui_selected = false
export var setting_name = ""

export var selected_scale = 1.1
signal pressed(is_selected)

func _ready():
	$Title.text = title
	update_selected(is_selected, false)
	
func _process(delta):
	if(is_ui_selected and visible):
		if(Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("ui_accept")):
			update_selected(!is_selected)
			$ChangeAudio.play()

func update_selected(_selected, emit_pressed = true):
	is_selected = _selected
	current_val = is_selected
	$Button.text = "o" if is_selected else "-" 
	
	if(emit_pressed):
		emit_signal("pressed", is_selected)

func _on_Button_pressed():
	update_selected(!is_selected)

func select():
	scale *= selected_scale
	is_ui_selected = true

func deselect():
	scale /= selected_scale
	is_ui_selected = false
