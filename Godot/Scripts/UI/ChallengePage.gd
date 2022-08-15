extends Node2D

var selected = 0
var panel_selection_scale = 1.1
var score_mult = 1.0

var buttons
var panels
var panel_num
var button_num
var ui_num

export var col_sep = 400
export var row_sep = 100
export var panels_per_col = 5
export var starting_panel_loc = Vector2.ZERO
export var ui_name = "ChallengePage"
# Called when the node enters the scene tree for the first time.
var more_pale_mod = 0.7
func _ready():
	buttons = [$BackButton, $ReadyButton]
	panels = $ChallengePanels.get_children()

	panel_num = len(panels)
	button_num = len(buttons)
	ui_num = panel_num + button_num

	Settings.apply_sound_settings()
	var score = HighScore.get_score("challenge")
	score = Global.point_num_to_string(Global.round_float(score, 2), ["b", "m"])
	$HighScore.text = "High Score: " + score
	select_ui_element(selected)

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
		back_to_main_menu()
	if(Input.is_action_just_pressed("ui_down")):
		select_next_ui_element()
	if(Input.is_action_just_pressed("ui_up")):
		select_last_ui_element()
	if(Input.is_action_just_pressed("ui_accept") and selected >= panel_num):
		buttons[selected-panel_num].emit_signal("pressed")

func select_next_ui_element():
	select_ui_element( (selected+1) % ui_num )

func select_last_ui_element():
	select_ui_element( (selected+ui_num-1) % ui_num )

func select_ui_element(ui_element_num):
	$SelectAudio.play()
	if(selected < len(panels)):
		deselect_panel(selected)
	else:
		buttons[selected-len(panels)].deselect()

	selected = ui_element_num

	if(selected < len(panels)):
		select_panel(selected)
	else:
		buttons[selected-len(panels)].select()


func select_panel(panel_num):
	if(panel_num < len(panels)):
		$ChallengePanels.get_child(panel_num).is_ui_selected = true
		$ChallengePanels.get_child(panel_num).scale *= panel_selection_scale
		$ChallengePanels.get_child(panel_num).find_node("Light2D").visible = true
	else:
		buttons[panel_num-len(panels)].select()

func deselect_panel(panel_num):
	if(panel_num < len(panels)):
		$ChallengePanels.get_child(panel_num).is_ui_selected = false
		$ChallengePanels.get_child(panel_num).scale /= panel_selection_scale
		$ChallengePanels.get_child(panel_num).find_node("Light2D").visible = false
	else:
		buttons[panel_num-len(panels)].deselect()

func change_panel(panel_num):
	if(panel_num == selected):
		return

	$SelectAudio.play()
	deselect_panel(selected)
	selected = panel_num
	select_panel(selected)

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

var current_appear_panel = 0
func _on_PanelAppearTimer_timeout():
	if(current_appear_panel == $ChallengePanels.get_child_count()):
		$PanelAppearTimer.stop()
		return
	$ChallengePanels.get_child(current_appear_panel).visible = true
	$PanelAppearAudio.play()
	current_appear_panel += 1

func save_challenge_panel_state():
	Global.ui_states[ui_name] = []
	for c in $ChallengePanels.get_children():
		Global.ui_states[ui_name].append(c.get_current_val())

func load_challenge_panel_state():
	for i in range($ChallengePanels.get_child_count()):
		$ChallengePanels.get_child(i).update_current_val(Global.ui_states[ui_name][i])

func back_to_main_menu():
	save_challenge_panel_state()
	get_tree().change_scene("res://Scenes/MainScenes/MainMenu.tscn")

func _on_BackButton_pressed():
	back_to_main_menu()

func _on_BackButton_mouse_entered():
	deselect_panel(selected)
	selected = len(panels)
	select_panel(selected)

func _on_ReadyButton_mouse_entered():
	deselect_panel(selected)
	selected = len(panels) + 1
	select_panel(selected)
