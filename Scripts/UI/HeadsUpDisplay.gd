extends CanvasLayer

var game_is_over = false
var can_unpause = false
var pause_audio_pitch_scale = 0.66
var is_pitching_music = false

func _process(delta):
#	if(game_is_over and Input.is_action_just_pressed("ui_cancel")):
#		return_to_menu()

	if(is_pitching_music):
		var target = pause_audio_pitch_scale if get_tree().paused else 1.0
		var current_scale = get_parent().find_node("AudioStreamPlayer2D").pitch_scale
		get_parent().find_node("AudioStreamPlayer2D").pitch_scale = move_toward(current_scale, target, delta)
		if(pause_audio_pitch_scale == current_scale):
			is_pitching_music = false
			
	if(game_is_over == false and Input.is_action_just_pressed("ui_cancel")):
		print("get_tree().paused", get_tree().paused)
		if(get_tree().paused):
			unpause()
		else:
			pause()
			
func unpause():
	is_pitching_music = true
	$PausePopup.hide()
	get_tree().paused = false

func pause():
	is_pitching_music = true
	can_unpause = false
	$PausePopup/PausePopupBufferTimer.start()
	$PausePopup.show()
	get_tree().paused = true
	
func return_to_menu():
	get_tree().change_scene("res://Scenes/MainScenes/MainMenu.tscn")

func update_health(health_count, has_sheild):
	for c in $HealthDisplay.get_children():
		c.visible = false
		
	for i in health_count:
		$HealthDisplay.get_child(i).visible = true
		
	if(has_sheild):
		get_node("HealthDisplay/Sheild").visible = true
	else:
		get_node("HealthDisplay/Sheild").visible = false
		
func update_bombs(bomb_count):
	for c in $BombDisplay.get_children():
		c.visible = false
		
	for i in bomb_count:
		$BombDisplay.get_child(i).visible = true
	
func update_points(points):
	$PointsLabel.text = "Points: " + Global.point_num_to_string(points, ["b", "m"])
	
func game_over(is_mission, mission_complete):
	$GameOverPopup.show()
	$GameOverPopup/GameOverLabel.text = "COMPLETE" if is_mission and mission_complete else "GAME OVER"
	game_is_over = true
	
func change_color(new_color):
	for c in get_children():
		c.modulate = new_color

func reset():
	$GameOverPopup.hide()

func _on_RestartButton_pressed():
	game_is_over = false
	get_parent().start_new_game()

func _on_MenuButton_pressed():
	get_tree().paused = false
	return_to_menu()

func _on_ShopButton_pressed():
	pass
	
func _on_ResumeButton_pressed():
	unpause()

func _on_OptionsButton_pressed():
	pass

func _on_PausePopupBufferTimer_timeout():
	can_unpause = true
