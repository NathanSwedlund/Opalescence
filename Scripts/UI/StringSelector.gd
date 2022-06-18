extends Node2D

export var title = "Title"

export var button_index = 0
export var setting_name = ""
export var is_ui_selected = false
export var selected_scale = 1.2

export var strings = []
var index = 0
var string_num

signal pressed(_value)
	
func _process(delta):
	if(is_ui_selected and visible):
		if(Input.is_action_just_pressed("ui_left")):
			_on_DecreaseButton_pressed()
		if(Input.is_action_just_pressed("ui_right")):
			_on_IncreaseButton_pressed()

func _ready():
	string_num = len(strings)
	$Title.text = title
	if(setting_name in Settings.saved_settings.keys()):
		for i in range(string_num):
			if(Settings.saved_settings[setting_name] == strings[i]):
				index = i
				update(false)
				

func _on_DecreaseButton_pressed():
	get_parent().select(button_index)
	index = (index - 1 + string_num) % string_num
	update()
	emit_signal("pressed", strings[index])

func _on_IncreaseButton_pressed():
	get_parent().select(button_index)
	index = (index + 1) % string_num
	update()
	emit_signal("pressed", strings[index])

func update(play_sound=true):
	if(play_sound):
		$ChangeAudio.play()
	$Value.text = strings[index]
	Settings.saved_settings[setting_name] = strings[index]
	
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
