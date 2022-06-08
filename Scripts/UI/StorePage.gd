extends Node2D

var selected = -1
var ui_element_num
var ui_elements

var buttons
var button_num

var panels
var panel_num

export var panel_sep_dist = 230
export var starting_panel_loc = Vector2.ZERO

var is_shifting = false
export var shift_speed = 1800.0

# Called when the node enters the scene tree for the first time.
func _ready():
	buttons = [$UI/BackButton]
	button_num = len(buttons)
	
	panels = $UI/Panels.get_children()
	panel_num = len(panels)
	
	ui_element_num = button_num + panel_num
	ui_elements = panels + buttons
	
	for i in range(panel_num):
		panels[i].position = starting_panel_loc
		panels[i].position.y += i * panel_sep_dist
		panels[i].page = self

	update_point_label()
	select(0)
	update_color()

func _process(delta):
	if(is_shifting):
		$UI/Panels.position.y = move_toward($UI/Panels.position.y, panel_sep_dist*selected * -1, shift_speed*delta)
		if($UI/Panels.position.y == panel_sep_dist*selected * -1):
			is_shifting = false
			panels[selected].select()
			update_color()
			$SelectAudio.play()
	else:
		if(Input.is_action_just_pressed("ui_up")):
			select_last()
		if(Input.is_action_just_pressed("ui_down")):
			select_next()
		if(Input.is_action_just_pressed("ui_cancel")):
			back_to_main_menu()
		if(Input.is_action_just_pressed("ui_accept")):
			if(selected < panel_num): # Shop Panel
				ui_elements[selected].try_buy()
			else: # Button
				ui_elements[selected].emit_signal("pressed")

func update_color():
	if(selected < panel_num):
		var c = panels[selected].modulate
		$PointsLabel.modulate = c
		$LastPanelButton.modulate = c
		$StoreLabel.modulate = c
		$UI/BackButton.modulate = c
		$Light2D.color = c
			
func select_next():
	select( (selected + 1) % ui_element_num )
	
func select_last():
	select( (selected - 1 + ui_element_num) % ui_element_num )
	
func select(num):
	if(num == selected):
		return 

	num %= ui_element_num
	
	ui_elements[selected].deselect()
	selected = num
	
	if(num < panel_num):
		is_shifting = true
	else:
		$SelectAudio.play()
		ui_elements[selected].select()
		
func update_point_label():
	$PointsLabel.text = "Points: " + str(Global.point_num_to_string(Settings.shop["points"], ["b", "m", "k"]))

func _on_BackButton_pressed():
	back_to_main_menu()

func back_to_main_menu():
	Settings.save()
	get_tree().change_scene("res://Scenes/MainScenes/MainMenu.tscn")

func _on_LastPanelButton_pressed():
	if(!is_shifting and selected != 0):
		select_last()

func _on_NextPanelButton_pressed():
	if(!is_shifting and selected != panel_num-1):
		select_next()

func _on_AddPointButton_pressed():
	Settings.shop["points"] += 1000000000
	update_point_label()

func _on_ResetButton_pressed():
	for p in panels:
		p.reset()
		Settings.shop = Settings.shop_default.duplicate()
