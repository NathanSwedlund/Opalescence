extends Node2D

export var title = ""
export var button_index = 0

export var is_selected = false
export var select_scale = 1.1

export var default_val = 0
var current_val = 0

var subpanels = []
var subpanel_num
var subpanel_index = 0

var subpanel_sep_x = 750
var is_shifting_subpanels = false
var shift_speed = 4000
var shift_x_target
var page
# Called when the node enters the scene tree for the first time.

func _ready():
	for c in $Panels.get_children():
		subpanels.append(c)
		
	subpanel_num = len(subpanels)
	var currentx = 0
	for sp in subpanels:
		sp.position.x = currentx
		currentx += subpanel_sep_x
		
	update_labels()
	
func _process(delta):
	if(! is_shifting_subpanels):
		if(page.should_ignore_input == false):
			if(is_selected and Input.is_action_just_pressed("ui_right")):
				shift_subpanel( (subpanel_index+1) % subpanel_num)
			if(is_selected and Input.is_action_just_pressed("ui_left")):
				shift_subpanel( (subpanel_index-1+subpanel_num) % subpanel_num)
	else:
		$Panels.position.x = move_toward($Panels.position.x, shift_x_target, shift_speed*delta)
		if(int($Panels.position.x) == int(shift_x_target)):
			page.resume_input_actions()
			is_shifting_subpanels = false	
			subpanels[subpanel_index].select()
			$SelectAudio.play()
			page.change_color(subpanels[subpanel_index].modulate)
			
		
func shift_subpanel(new_index):
	page.stop_input_actions()	
	subpanels[subpanel_index].deselect()
	subpanel_index = new_index
	is_shifting_subpanels = true
	shift_x_target = int(-subpanel_sep_x*subpanel_index*$Panels.scale.x)

func _on_BuyButton_pressed():
	try_buy()
	
func try_buy():
	subpanels[subpanel_index].try_buy()
	
func update():
	for sp in subpanels:
		sp.update()
		
func update_labels():
	$Title.text = title
	for sp in subpanels:
		sp.update_labels()
		
func select():
	subpanels[subpanel_index].select()
	scale *= select_scale
	is_selected = true
	page.change_color(subpanels[subpanel_index].modulate)

func deselect():
	subpanels[subpanel_index].deselect()
	scale /= select_scale
	is_selected = false
	
func set_page(_page):
	page = _page
	for sp in subpanels:
		sp.page = page

func reset():
	for sp in subpanels:
		sp.reset()
