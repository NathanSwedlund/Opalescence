extends CanvasLayer

var game_is_over = false
var can_unpause = false
var pause_audio_pitch_scale = 0.66
var is_pitching_music = false

func _ready():
	if(Settings.get_setting_if_exists(Settings.player, "can_bomb", true) == false):
		$BombDisplay.visible = false

func _process(delta):
	if(is_pitching_music):
		var target = pause_audio_pitch_scale if get_tree().paused else 1.0
		var current_scale = get_parent().find_node("MusicShuffler").pitch_scale
		get_parent().find_node("MusicShuffler").pitch_scale = move_toward(current_scale, target, delta)
		if(pause_audio_pitch_scale == current_scale):
			is_pitching_music = false
	
	if(game_is_over == false and Input.is_action_just_pressed("ui_cancel")):
		if(get_tree().paused):
			unpause()
		else:
			pause()

func unpause():
	$PausePopup/Buttons.is_active = false
	is_pitching_music = true
	$PausePopup.hide()
	get_tree().paused = false

func pause():
	$PausePopup/Buttons.is_active = true
	is_pitching_music = true
	can_unpause = false
	$PausePopup/PausePopupBufferTimer.start()
	$PausePopup.show()
	get_tree().paused = true

func return_to_menu():
	get_tree().change_scene(Global.return_scene)
		

func update_health(health_count, has_shield):
	$HealthDisplay/Label.text = "x "+str(health_count-1)
	$HealthDisplay/Shield.visible = has_shield

func update_bombs(bomb_count):
	for c in $BombDisplay.get_children():
		c.visible = false

	for i in bomb_count:
		$BombDisplay.get_child(i).visible = true

func update_points(points):
	$PointsLabel.text = "Points: " + Global.point_num_to_string(Global.round_float(points, 2), ["b", "m"])

func game_over(is_mission, mission_complete):
	$GameOverPopup.show()
	$GameOverPopup/Buttons.is_active = true
	$GameOverPopup/GameOverLabel.text = "COMPLETE" if is_mission and mission_complete else "GAME OVER"
	game_is_over = true

func change_color(new_color):
	for c in get_children():
		if(c.get("modulate") != null):
			c.modulate = new_color
			
	$GameOverPopup/Buttons/MenuButton/Light2D.color = new_color
	$GameOverPopup/Buttons/ShopButton/Light2D.color = new_color
	$GameOverPopup/Buttons/RestartButton/Light2D.color = new_color
	$PausePopup/Buttons/MenuButton/Light2D.color = new_color
	$PausePopup/Buttons/ResumeButton/Light2D.color = new_color
	$PausePopup/Buttons/OptionsButton/Light2D.color = new_color
	

func reset():
	$GameOverPopup/Buttons.is_active = false
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
