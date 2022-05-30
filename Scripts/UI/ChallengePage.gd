extends Node2D

var current_panel_selected = 0
var panel_selection_scale = 1.1
var score_mult = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	Settings.apply_sound_settings()
	var score = HighScore.get_score("challenge")
	score = Global.point_num_to_string(Global.round_float(score, 2), ["b", "m"])
	$HighScore.text = "High Score: " + score

func _process(delta):
	if(Input.is_action_just_pressed("ui_cancel")):
		get_tree().change_scene("res://Scenes/MainScenes/MainMenu.tscn")
	if(Input.is_action_just_pressed("ui_down")):
		var panel_num = (current_panel_selected + 1) % $ChallengePanels.get_child_count()
		select_panel(panel_num)
	if(Input.is_action_just_pressed("ui_up")):
		var panel_num = (current_panel_selected  - 1 + $ChallengePanels.get_child_count()) % $ChallengePanels.get_child_count()
		select_panel(panel_num)
	
	if(Input.is_action_just_pressed("controller_start")):
		_on_ReadyButton_pressed()

func select_panel(panel_num):
		$SelectAudio.play()
		$ChallengePanels.get_child(current_panel_selected).is_ui_selected = false
		$ChallengePanels.get_child(current_panel_selected).scale /= panel_selection_scale
		$ChallengePanels.get_child(current_panel_selected).find_node("Light2D").visible = false

		current_panel_selected = panel_num
		
		$ChallengePanels.get_child(current_panel_selected).is_ui_selected = true
		$ChallengePanels.get_child(current_panel_selected).scale *= panel_selection_scale
		$ChallengePanels.get_child(current_panel_selected).find_node("Light2D").visible = true

func update_global_score_mult():
	print("update_global_score_mult")
	score_mult = 1.0
	for c in $ChallengePanels.get_children():
		score_mult *= c.score_mult
	
	$ScoreMult.text = "Score Multiplier: X" + str(score_mult)

func _on_ReadyButton_pressed():
	for c in $ChallengePanels.get_children():
		for d in [Settings.world, Settings.factory, Settings.enemy, Settings.player]:
			for key in d.keys():
				if(c.setting_name == key):
					print("Setting ", key, " to ", c.current_val)
					d[key] = c.current_val

	Settings.world["points_scale"] = score_mult
	Settings.world["mission_title"] = "challenge"
	get_tree().change_scene("res://Scenes/MainScenes/World.tscn")

var current_panel = 0
func _on_PanelAppearTimer_timeout():
	if(current_panel == $ChallengePanels.get_child_count()):
		$PanelAppearTimer.stop()
		return
	$ChallengePanels.get_child(current_panel).visible = true
	$PanelAppearAudio.play()
	current_panel += 1
