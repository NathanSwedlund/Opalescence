extends Node2D

var selected_button = 0
var last_selected = 0
export var button_count = 4
export var is_active = false

# Called when the node enters the scene tree for the first time.
func _ready():
	get_child(selected_button).select()
	pass # Replace with function body.

func action_pressed(action):
	return Input.is_action_just_pressed(action)

func _process(_delta):
	if(is_active and get_child(selected_button).visible):
		print(visible)
		if(get_parent().is_class("Popup")):
			if(get_parent().visible == false):
				return 
		if(action_pressed("ui_down") or (action_pressed("ui_focus_next") and ! action_pressed("ui_focus_prev")) ):
			selected_button = (selected_button + 1) % button_count
			get_parent().get_parent().find_node("ButtonSelectAudio").play()
		elif(action_pressed("ui_up") or action_pressed("ui_focus_prev")):
			selected_button = (selected_button + button_count-1) % button_count
			get_parent().get_parent().find_node("ButtonSelectAudio").play()
		elif(action_pressed("ui_accept")):
			get_child(selected_button).emit_signal("pressed")
			
		if(selected_button != last_selected):
			get_child(last_selected).deselect()
			last_selected = selected_button
			get_child(selected_button).select()
