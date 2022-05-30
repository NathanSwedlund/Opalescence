extends Button

export var left_margin_on_hover = 600
export var button_index = -1
export var button_shift_index = -1
var initital_left_margin

onready var selection_controller = get_parent()
		
func _ready():
	#selection_controller
	initital_left_margin = margin_left

func deselect():
	margin_left = initital_left_margin
	$Light2D.visible = false
	$Particles2D.emitting = false
	$Particles2D.visible = false

func select():
	if(selection_controller.get("selected_button") != null):
		selection_controller.selected_button = button_index
	margin_left = left_margin_on_hover
	$Light2D.visible = true
	$Particles2D.emitting = true
	$Particles2D.visible = true

func mouse_entered():
	select()

func mouse_exited():
	deselect()
