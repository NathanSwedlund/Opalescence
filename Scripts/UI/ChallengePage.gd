extends Node2D

var current_panel_selected = 0
var panel_selection_scale = 1.1
var score_mult = 1.0

export var col_sep = 400
export var row_sep = 100
export var panels_per_col = 5
export var starting_panel_loc = Vector2.ZERO
export var ui_name = "ChallengePage"
# Called when the node enters the scene tree for the first time.
var more_pale_mod = 0.7
func _ready():
	Settings.apply_sound_settings()
	var score = HighScore.get_score("challenge")
	score = Global.point_num_to_string(Global.round_float(score, 2), ["b", "m"])
	$HighScore.text = "High Score: " + score
	select_panel(current_panel_selected)
	for i in range($ChallengePanels.get_child_count()):
		var c = $ChallengePanels.get_child(i)
		# setting position
		var col_num = i/panels_per_col
		var row_nun = i-(col_num*panels_per_col)
		c.position = Vector2(starting_panel_loc.x+col_num*col_sep, starting_panel_loc.y+row_nun*row_sep) 
		randomize()
		
		# setting colors
		if(c.get("min_is_harder") != null): # float selector
			if(c.min_is_harder):
				c.max_color = Settings.saved_settings["colors"][randi()%len(Settings.saved_settings["colors"])]
				c.min_color = Color(c.max_color.r+more_pale_mod, c.max_color.g+more_pale_mod, c.max_color.b+more_pale_mod)
			else:
				c.min_color = Settings.saved_settings["colors"][randi()%len(Settings.saved_settings["colors"])]
				c.max_color = Color(c.min_color.r+more_pale_mod, c.min_color.g+more_pale_mod, c.min_color.b+more_pale_mod)
				
		elif(c.get("selected_is_harder") != null):
			if(c.selected_is_harder):
				c.unselected_color = Settings.saved_settings["colors"][randi()%len(Settings.saved_settings["colors"])]
				c.selected_color = Color(c.unselected_color.r+more_pale_mod, c.unselected_color.g+more_pale_mod, c.unselected_color.b+more_pale_mod)
			else:
				c.selected_color = Settings.saved_settings["colors"][randi()%len(Settings.saved_settings["colors"])]
				c.unselected_color = Color(c.selected_color.r+more_pale_mod, c.selected_color.g+more_pale_mod, c.selected_color.b+more_pale_mod)
		c.update_color()

	if(ui_name in Global.ui_states.keys()):
		load_challenge_panel_state()

var selecting_ready_button = false
func _process(delta):
	if(Input.is_action_just_pressed("ui_cancel")):
		save_challenge_panel_state()
		get_tree().change_scene("res://Scenes/MainScenes/MainMenu.tscn")
	if(Input.is_action_just_pressed("ui_down")):
		select_next(true)
	if(Input.is_action_just_pressed("ui_up")):
		select_next(false)
	if(Input.is_action_just_pressed("controller_start") or (Input.is_action_just_pressed("ui_accept") and selecting_ready_button)):
		_on_ReadyButton_pressed()

func select_next(going_up=true):
	var change_num = 1 if going_up else -1
	$SelectAudio.play()
	
	if( (!going_up and current_panel_selected == 0) or (going_up and current_panel_selected==$ChallengePanels.get_child_count()-1)):
		if(!selecting_ready_button):
			deselect_panel(current_panel_selected)
			selecting_ready_button = true
			$ReadyButton.select()
		else:
			current_panel_selected = (current_panel_selected + change_num + $ChallengePanels.get_child_count()) % $ChallengePanels.get_child_count()
			select_panel(current_panel_selected)
			selecting_ready_button = false
			$ReadyButton.deselect()
	else:
		if(selecting_ready_button):
			selecting_ready_button = false
			$ReadyButton.deselect()
			select_panel(current_panel_selected)
		else:
			deselect_panel(current_panel_selected)
			current_panel_selected = (current_panel_selected + change_num + $ChallengePanels.get_child_count()) % $ChallengePanels.get_child_count()
			select_panel(current_panel_selected)
			selecting_ready_button = false
		
func select_panel(panel_num):
	$ChallengePanels.get_child(current_panel_selected).is_ui_selected = true
	$ChallengePanels.get_child(current_panel_selected).scale *= panel_selection_scale
	$ChallengePanels.get_child(current_panel_selected).find_node("Light2D").visible = true

func deselect_panel(panel_num):
	$ChallengePanels.get_child(current_panel_selected).is_ui_selected = false
	$ChallengePanels.get_child(current_panel_selected).scale /= panel_selection_scale
	$ChallengePanels.get_child(current_panel_selected).find_node("Light2D").visible = false

func update_global_score_mult():
	score_mult = 1.0
	for c in $ChallengePanels.get_children():
		score_mult *= c.score_mult

	$ScoreMult.text = "Score Multiplier: X" + str(score_mult)

func _on_ReadyButton_pressed():
	for c in $ChallengePanels.get_children():
		for d in [Settings.world, Settings.factory, Settings.enemy, Settings.player]:
			for key in d.keys():
				if(c.setting_name == key):
					d[key] = c.current_val
					
	Settings.player["starting_health"] = $ChallengePanels/ChallengePanel13.current_val+1 # health + 1
	Settings.world["points_scale"] = score_mult
	Settings.world["mission_title"] = "challenge"
	save_challenge_panel_state()
	Global.return_scene = "res://Scenes/HelperScenes/UI/ChallengePage.tscn"
	get_tree().change_scene("res://Scenes/MainScenes/World.tscn")

var current_panel = 0
func _on_PanelAppearTimer_timeout():
	if(current_panel == $ChallengePanels.get_child_count()):
		$PanelAppearTimer.stop()
		return
	$ChallengePanels.get_child(current_panel).visible = true
	$PanelAppearAudio.play()
	current_panel += 1
	
func save_challenge_panel_state():
	Global.ui_states[ui_name] = []
	for c in $ChallengePanels.get_children():
		Global.ui_states[ui_name].append(c.get_current_val())

func load_challenge_panel_state():
	for i in range($ChallengePanels.get_child_count()):
		$ChallengePanels.get_child(i).update_current_val(Global.ui_states[ui_name][i])
