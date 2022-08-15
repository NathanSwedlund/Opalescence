extends Button

export var right_margin_mod_on_hover = 200
export var button_index = -1
export var button_shift_index = -1
var is_selected = false
onready var selection_controller = get_parent()

func deselect():
	if(!is_selected):
		return

	is_selected = false
	margin_right -= right_margin_mod_on_hover
	$Light2D.visible = false
	$Particles2D.emitting = false
	$Particles2D.visible = false

func select():
	if(is_selected):
		return

	is_selected = true
	if(get_parent().get("selected_button") != null):
		if(get_parent().selected_button != button_index):
			get_parent().select(button_index)

#	if(get_parent().get("selected") != null):
#		if(get_parent().selected != button_index):
#			get_parent().select(button_index)

	margin_right += right_margin_mod_on_hover
	$Light2D.visible = true
	$Particles2D.emitting = true
	$Particles2D.visible = true

func mouse_entered():
	select()

func mouse_exited():
	deselect()
