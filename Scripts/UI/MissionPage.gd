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
		Global.ui_states[ui_name] = selected
		get_tree().change_scene("res://Scenes/MainScenes/MainMenu.tscn")
		
	get_parent().find_node("Particles2D").visible = !is_shifting

	if(is_shifting == false):
		if(Input.is_action_just_pressed("ui_accept")):
			load_scene_from_panel()
		
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
	print(Global.ui_states)
	
	Global.return_scene = scene_page_selector_is_in
	Settings.world = $Pages.get_child(selected).world_settings.duplicate()
	Settings.player = $Pages.get_child(selected).player_settings.duplicate()
	Settings.enemy = $Pages.get_child(selected).enemy_settings.duplicate()
	Settings.factory = $Pages.get_child(selected).factory_settings.duplicate()
	
	# Adding any setting to the world settings if they werent included in the mission panel
	var dicts = [Settings.world, Settings.player, Settings.enemy, Settings.factory]
	var defaults = [Settings.world_default, Settings.player_default, Settings.enemy_default, Settings.factory_default]
	for i in range(len(dicts)):
		for key in defaults[i].keys():
			if( (key in dicts[i]) == false ):
				dicts[i][key] = defaults[i][key]
	
	get_tree().change_scene("res://Scenes/MainScenes/World.tscn")

func start_shifting():
	print(selected)
	$Pages.get_child(selected).scale /= selected_scale
	$Pages.get_children()[selected].find_node("Description").visible = false
	$Pages.get_children()[selected].modulate.a = 0.2
	
	selected += 1 if shift_right else -1

	is_shifting = true
	$Pages.get_child(selected).scale *= selected_scale
	print(selected)

func finish_shifting():
	get_parent().find_node("Particles2D").modulate = $Pages.get_child(selected).modulate
	get_parent().find_node("Particles2D").find_node("Light2D").color = $Pages.get_child(selected).modulate
	get_parent().find_node("MissionContainerFrame").modulate = $Pages.get_child(selected).modulate
	get_parent().find_node("MissionContainerFrame").modulate.r -= 0.1
	get_parent().find_node("MissionContainerFrame").modulate.g -= 0.1
	get_parent().find_node("MissionContainerFrame").modulate.b -= 0.1
	get_parent().find_node("MissionContainerFrame").modulate.a = 1.0
	$Pages.get_children()[selected].find_node("Description").visible = true
	$Pages.get_children()[selected].modulate.a = 1.0
	get_parent().find_node("Label").modulate = $Pages.get_child(selected).modulate
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
	$Pages.get_child(selected).find_node("Description").visible = true
	
	get_parent().find_node("MissionContainerFrame").modulate = $Pages.get_child(p).modulate
	get_parent().find_node("MissionContainerFrame").modulate.r -= 0.1
	get_parent().find_node("MissionContainerFrame").modulate.g -= 0.1
	get_parent().find_node("MissionContainerFrame").modulate.b -= 0.1
	get_parent().find_node("Particles2D").modulate = $Pages.get_child(p).modulate
	get_parent().find_node("Label").modulate = $Pages.get_child(p).modulate
