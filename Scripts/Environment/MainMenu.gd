extends Node2D

var current_button_selection = 0
var is_shifting_button_selection = false
var current_shifting_index = 0
var target_button_selection

var button_selections

func _ready():
	button_selections = [$MenuCanvas/ButtonSelectionController1, $MenuCanvas/ButtonSelectionController2]

func _on_ChallengeButton_pressed():
#	Settings.settings["current_game_mode"] = "challenge"
	get_tree().change_scene("res://Scenes/HelperScenes/UI/ChallengePage.tscn")

var last_color = Color.white
func _process(_delta):
	if($Player.modulate != last_color):
		last_color = $Player.modulate
		$MenuCanvas/OpalescenceLabel.modulate = last_color
		$MenuCanvas/ButtonSelectionController1.modulate = last_color
		$MenuCanvas/ButtonSelectionController2.modulate = last_color
		for c in $MenuCanvas/ButtonSelectionController1.get_children():
			c.get_node("Light2D").color = last_color
		for c in $MenuCanvas/ButtonSelectionController2.get_children():
			c.get_node("Light2D").color = last_color

func _on_QuitButton_pressed():
	get_tree().quit()

func _on_ArcadeButton_pressed():
	get_tree().change_scene("res://Scenes/HelperScenes/UI/MissionPage.tscn")

func _on_TutorialsButton_pressed():
	get_tree().change_scene("res://Scenes/HelperScenes/UI/TutorialsMissionPage.tscn")

func toggle_button_selection():
	$ButtonShiftTimer.start()
	
func _on_PlayButton_pressed():
	shift_button_selection(1)

func _on_BackButton_pressed():
	shift_button_selection(0)

func _on_StandardButton_pressed():
	Settings.world["mission_title"] = "standard"
	get_tree().change_scene("res://Scenes/MainScenes/World.tscn")

func shift_button_selection(button_selection_num):
	if(button_selection_num != current_button_selection):
		target_button_selection = button_selection_num
		is_shifting_button_selection = true
		current_shifting_index = 0
		$ButtonShiftTimer.start()
		button_selections[current_button_selection].is_active = false

func _on_ButtonShiftTimer_timeout():
	var shifted_any = false
	for c in button_selections[current_button_selection].get_children():
		if(c.button_shift_index == current_shifting_index):
			c.visible = false
			shifted_any = true
	
	for c in button_selections[target_button_selection].get_children():
		if(c.button_shift_index == current_shifting_index):
			c.visible = true
			shifted_any = true
	
	if(shifted_any):
		$ButtonShiftAudio.play()
		current_shifting_index += 1
	else:
		button_selections[target_button_selection].is_active = true
		current_button_selection = target_button_selection
		current_shifting_index = 0
		is_shifting_button_selection = false
		$ButtonShiftTimer.stop()
