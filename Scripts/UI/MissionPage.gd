extends Node2D

export var shift_dist = -260
export var shift_speed = 3000
export var first_panel_start_x = 150

var is_shifting = false
var shift_right = true

var selected = 0
var selected_scale = 1.25

var panels = null
var panel_num = 0

export var scene_page_selector_is_in = ""
export var ui_name = ""
export var ui_modulate_saturation_mod = -0.15

func about_to_change_scenes():
	Global.ui_states[ui_name] = current_panel

func _ready():
	Settings.apply_sound_settings()
	Settings.reset_settings()
	panels = $Pages.get_children()
	panel_num = len(panels) # The two audio nodes aren't panels
	
	if(ui_name in Global.ui_states.keys()):
		var state =  Global.ui_states[ui_name]
		for i in $Pages.get_children():
			i.visible = true
		select(state)
	else:
		select(current_panel)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(Input.is_action_just_pressed("ui_cancel")):
		back_to_main_menu()
		
	get_parent().find_node("Particles2D").visible = !is_shifting

	if(is_shifting == false):
		if(Input.is_action_just_pressed("ui_left") and selected != 0):
			shift_right = false
			start_shifting()
			
		if(Input.is_action_just_pressed("ui_right") and selected != panel_num-1):
			shift_right = true
			start_shifting()
	else:
		if(shift_right):
			position.x = move_toward(position.x, shift_dist * selected, delta * shift_speed)
			if(position.x <= shift_dist * selected):
				finish_shifting()
		else:
			position.x = move_toward(position.x, shift_dist * selected, delta * shift_speed)
			if(position.x >= shift_dist * selected):
				finish_shifting()

func load_scene_from_panel():
	Global.ui_states[ui_name] = selected
	Global.return_scene = scene_page_selector_is_in
	
	# Adding any setting to the world settings if they werent included in the mission panel
	var dicts = [Settings.world, Settings.player, Settings.enemy, Settings.factory]
	var c = $Pages.get_child(selected)
	
	for key in c.settings.keys():
		for i in range(len(dicts)):
			if(c.settings[key] != null and key in dicts[i]):
				dicts[i][key] = c.settings[key]
	
	get_tree().change_scene("res://Scenes/MainScenes/World.tscn")

func start_shifting():
	for i in range(panel_num):
		print($Pages.get_child(i).scale)
		
	$Pages.get_child(selected).scale /= selected_scale
	$Pages.get_children()[selected].find_node("Description").visible = false
	$Pages.get_children()[selected].modulate.a = 0.2
	
	selected += 1 if shift_right else -1

	is_shifting = true
	$Pages.get_child(selected).scale *= selected_scale

func change_color(color):
	get_parent().find_node("Particles2D").modulate = color
	get_parent().find_node("Particles2D").find_node("Light2D").color = color
	
	var mission_container_frame  = get_parent().find_node("MissionContainerFrame")
	mission_container_frame.modulate = color
	mission_container_frame.modulate.r += ui_modulate_saturation_mod
	mission_container_frame.modulate.g += ui_modulate_saturation_mod
	mission_container_frame.modulate.b += ui_modulate_saturation_mod
	mission_container_frame.modulate.a = 1.0
	
	var next_panel_button = get_parent().find_node("Buttons").find_node("NextPanelButton")
	next_panel_button.modulate = color
	next_panel_button.modulate.r += ui_modulate_saturation_mod * -3
	next_panel_button.modulate.g += ui_modulate_saturation_mod * -3
	next_panel_button.modulate.b += ui_modulate_saturation_mod * -3
	next_panel_button.modulate.a = 1.0
	
	var last_panel_button = get_parent().find_node("Buttons").find_node("LastPanelButton")
	last_panel_button.modulate = color
	last_panel_button.modulate.r += ui_modulate_saturation_mod * -3
	last_panel_button.modulate.g += ui_modulate_saturation_mod * -3
	last_panel_button.modulate.b += ui_modulate_saturation_mod * -3
	last_panel_button.modulate.a = 1.0
	
	var ready_button = get_parent().find_node("Buttons").find_node("ButtonSelectionController").find_node("ReadyButton")
	ready_button.modulate = color
	ready_button.modulate.r += ui_modulate_saturation_mod * -3
	ready_button.modulate.g += ui_modulate_saturation_mod * -3
	ready_button.modulate.b += ui_modulate_saturation_mod * -3
	ready_button.modulate.a = 1.0
	
	var back_button = get_parent().find_node("Buttons").find_node("ButtonSelectionController").find_node("BackButton")
	back_button.modulate = color
	back_button.modulate.r += ui_modulate_saturation_mod * -3
	back_button.modulate.g += ui_modulate_saturation_mod * -3
	back_button.modulate.b += ui_modulate_saturation_mod * -3
	back_button.modulate.a = 1.0
	
	$Pages.get_children()[selected].find_node("Description").visible = true
	$Pages.get_children()[selected].modulate.a = 1.0
	get_parent().find_node("Label").modulate = color
	get_parent().find_node("Label").modulate.a = 1.0
	
	
func finish_shifting():
	change_color($Pages.get_child(selected).modulate)
	$SelectSound.play()
	position.x = shift_dist * selected
	is_shifting = false

var current_panel = 0
func _on_PanelAppearTimer_timeout():
	if(ui_name in Global.ui_states.keys()):
		$PanelAppearTimer.stop()
		return
		
	if(current_panel == $Pages.get_child_count()):
		$PanelAppearTimer.stop()
		return
	
	$Pages.get_child(current_panel).visible = true
	$PanelAppearAudio.play()
	current_panel += 1

func panel_pressed(_index):
	if(_index == selected):
		load_scene_from_panel()
	elif(_index < selected):
		shift_right = false
		start_shifting()
	else:
		shift_right = true
		start_shifting()

func _on_NextPanelButton_pressed():
	if(selected != panel_num-1):
		shift_right = true
		start_shifting()

func _on_LastPanelButton_pressed():
	if(selected != 0):
		shift_right = false
		start_shifting()
		
func select(p):
	$Pages.get_child(selected).scale /= selected_scale
	selected = p
	$Pages.get_child(selected).scale *= selected_scale
	for i in range(panel_num):
		$Pages.get_child(i).find_node("Description").visible = false
		$Pages.get_child(i).position.x = i * -shift_dist + first_panel_start_x
		$Pages.get_child(i).index = i
		$Pages.get_child(i).page_container = self
		if(i != selected):
			$Pages.get_child(i).modulate.a = 0.2
		
	position.x += shift_dist * selected
	change_color($Pages.get_child(selected).modulate)

func back_to_main_menu():
	Global.ui_states[ui_name] = selected
	get_tree().change_scene("res://Scenes/MainScenes/MainMenu.tscn")

func _on_ReadyButton_pressed():
	load_scene_from_panel()

func _on_BackButton_pressed():
	back_to_main_menu()
