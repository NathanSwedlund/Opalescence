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

# Called when the node enters the scene tree for the first time.
func _ready():
	Settings.reset_settings()
	panels = $Pages.get_children()
	panel_num = len(panels)-2 # The two audio nodes aren't panels
	
	for i in range(panel_num):
		$Pages.get_children()[i].find_node("Description").visible = false
		$Pages.get_children()[i].position.x = i * -shift_dist + first_panel_start_x
		print(i * -shift_dist + first_panel_start_x)
		
	$Pages.get_child(0).find_node("Description").visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(Input.is_action_just_pressed("ui_cancel")):
		get_tree().change_scene("res://Scenes/MainScenes/MainMenu.tscn")
		
	get_parent().find_node("Particles2D").visible = !is_shifting

	if(is_shifting == false):
		if(Input.is_action_just_pressed("ui_accept")):
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

func start_shifting():
	print(selected)
	$Pages.get_child(selected).scale /= selected_scale
	$Pages.get_children()[selected].find_node("Description").visible = false
	selected += 1 if shift_right else -1

	is_shifting = true
	$Pages.get_child(selected).scale *= selected_scale
	print(selected)

func finish_shifting():
	get_parent().find_node("Particles2D").modulate = $Pages.get_child(selected).modulate
	$Pages.get_children()[selected].find_node("Description").visible = true
	$SelectSound.play()
	position.x = shift_dist * selected			
	is_shifting = false

var current_panel = 0
func _on_PanelAppearTimer_timeout():
	if(current_panel == $Pages.get_child_count()):
		$PanelAppearTimer.stop()
		return
	
	$Pages.get_child(current_panel).visible = true
	$PanelAppearAudio.play()
	current_panel += 1

