extends Node2D

func _on_ChallengeButton_pressed():
#	Settings.settings["current_game_mode"] = "challenge"
	get_tree().change_scene("res://Scenes/HelperScenes/UI/ChallengePage.tscn")

var last_color = Color.white
func _process(_delta):
	if($Player.modulate != last_color):
		last_color = $Player.modulate
		$MenuCanvas/OpalescenceLabel.modulate = last_color
		$MenuCanvas/ButtonSelectionController.modulate = last_color
		for c in $MenuCanvas/ButtonSelectionController.get_children():
			c.get_node("Light2D").color = last_color

func _on_QuitButton_pressed():
	get_tree().quit()

func _on_ArcadeButton_pressed():
	get_tree().change_scene("res://Scenes/HelperScenes/UI/MissionPage.tscn")

func _on_TutorialsButton_pressed():
	get_tree().change_scene("res://Scenes/HelperScenes/UI/TutorialsMissionPage.tscn")
