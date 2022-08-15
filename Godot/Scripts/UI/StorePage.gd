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
var buying_event_is_playing = false
var should_ignore_input = false
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
		panels[i].set_page(self)

	update_point_label()
	select(0)
	update_color()
	if(Settings.shop["monocolor_color"] != null):
		modulate = Settings.shop["monocolor_color"]

func _process(delta):
	if(is_shifting):
		$UI/Panels.position.y = move_toward($UI/Panels.position.y, panel_sep_dist*selected * -1, shift_speed*delta)
		if($UI/Panels.position.y == panel_sep_dist*selected * -1):
			is_shifting = false
			panels[selected].select()
			update_color()
			$SelectAudio.play()
			resume_input_actions()
	elif(should_ignore_input == false):
		if(Input.is_action_just_pressed("ui_up")):
			select_last()
		if(Input.is_action_just_pressed("ui_down")):
			select_next()
		if(Input.is_action_just_pressed("ui_accept")):
			if(selected < panel_num): # Shop Panel
				ui_elements[selected].try_buy()
			else: # Button
				ui_elements[selected].emit_signal("pressed")
	if(Input.is_action_just_pressed("ui_cancel")):
			back_to_main_menu()

func update_color():
	if(selected < panel_num):
		var c = panels[selected].modulate
		change_color(c)

func change_color(c):
	$PointsLabel.modulate = c
	$PointsLabel2.modulate = c
	$LastPanelButton.modulate = c
	$StoreLabel.modulate = c
	$UI/BackButton.modulate = c
	$Light2D.color = c
	$UI/SepBar.modulate = c
	$UI/SepBar2.modulate = c
	for p in $UI/Panels.get_children():
		p.modulate = c

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
		stop_input_actions()
	else:
		$SelectAudio.play()
		ui_elements[selected].select()

func update_point_label():
	$PointsLabel2.text = str(Global.point_num_to_string(int(Settings.shop["points"]), ["b", "m", "k"]))

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
	Settings.shop["points"] += 1000000
	update_point_label()

func _on_ResetButton_pressed():
	for p in panels:
		p.reset()
		Settings.shop = Settings.shop_default.duplicate()


func _on_SuperPanelLastButton_pressed():
	if(should_ignore_input):
		return

	Input.action_press("ui_left")


func _on_SuperPanelNextButton_pressed():
	if(should_ignore_input):
		return
	Input.action_press("ui_right")

var is_deducting_points = false
var current_point_deductions = 0
var base_total_point_deductions = 18
var target_point_deductions
var previous_points
var current_price
var current_deduct_juice_scale
var end_points_val
func start_point_deduction_event(price, juice_scale):
	current_price = price
	is_deducting_points = true
	current_deduct_juice_scale = juice_scale
	$PointLabelEventTimer.start()
	target_point_deductions = base_total_point_deductions * current_deduct_juice_scale
	end_points_val = int(Settings.shop["points"]-current_price)


func _on_PointLabelEventTimer_timeout():
	if(current_point_deductions < target_point_deductions):
		current_point_deductions += 1
		Settings.shop["points"] = move_toward(Settings.shop["points"], Settings.shop["points"]-current_price, float(current_price)/target_point_deductions)
		$PointDeductAudio.play()
		update_point_label()
	else:
		is_deducting_points = false
		current_point_deductions = 0
		$PointLabelEventTimer.stop()
		Settings.shop["points"] = end_points_val
		update_point_label()
		Settings.save()

func stop_input_actions():
	should_ignore_input = true

func resume_input_actions():
	should_ignore_input = false
