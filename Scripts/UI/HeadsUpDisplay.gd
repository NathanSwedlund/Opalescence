extends CanvasLayer

var game_is_over = false
var can_unpause = false
var pause_audio_pitch_scale = 0.66
var is_pitching_music = false

func _ready():
	if(Settings.get_setting_if_exists(Settings.player, "can_bomb", true) == false):
		$BombDisplay.visible = false

var is_racking_points = false
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
			
	if(is_racking_points and Input.is_action_just_pressed("ui_cancel")):# or Input.is_action_just_pressed("ui_accept"))):
		finish_racking()

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
	get_tree().paused = false	
	get_tree().change_scene(Global.return_scene)

func update_health(health_count, has_shield):
	$HealthDisplay/Label.text = "x "+str(health_count-1)
	$HealthDisplay/Shield.visible = has_shield

func update_bombs(bomb_count):
	if(bomb_count == 0):
		$BombDisplay.visible = false
	elif(bomb_count == 1):
		$BombDisplay.visible = true
		$BombDisplay/BombLabel.visible = false
	else:
		$BombDisplay.visible = true
		$BombDisplay/BombLabel.visible = true
		$BombDisplay/BombLabel.text = str(Global.player.current_bombs)
		
func update_points(points):
	$PointsLabel.text = "Points: " + Global.point_num_to_string(Global.round_float(points, 2), ["b", "m"])

func game_over(is_mission, mission_complete):
	point_add_popup_event()
	print("Global.player.points, ", Global.player.points)
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
	if(get_parent().get_node("LevelController") != null):
		get_parent().get_node("LevelController").modulate = new_color

func reset():
	$GameOverPopup/Buttons.is_active = false
	$GameOverPopup.hide()

func _on_RestartButton_pressed():
	done_racking_points = false
	Global.points_this_round = 0
	return_to_menu_after_done_racking = false
	game_is_over = false
	get_parent().start_new_game()

var return_to_menu_after_done_racking = false
var done_racking_points = false
func _on_MenuButton_pressed():
	Global.player._on_BulletTime_timeout() # to prevent point racking from being slowed by bullet time
	
	return_to_menu_after_done_racking = true
	if(done_racking_points or Global.points_this_round == 0):
		return_to_menu()
	else:
		$PausePopup.hide()
		point_add_popup_event()

var points_this_round
var point_num1
var point_num2
var point_add_music_mod = 10
var default_token_reward = 0
func point_add_popup_event():
	if(done_racking_points):
		return
	
	is_racking_points = true
	get_parent().find_node("MusicShuffler").volume_db -= point_add_music_mod
	
	points_this_round = Global.points_this_round
	point_num1 = points_this_round
	point_num2 = Settings.shop["points"]
	Settings.shop["points"] += points_this_round
	
	$PointAddPopup/PointsLabel.text = "Points Earned: " + Global.point_num_to_string(points_this_round)
	$PointAddPopup/TotalPointsLabel.text = "Total Points: " + Global.point_num_to_string(Settings.shop["points"])
	
	var tokens_this_round = default_token_reward
	tokens_this_round = int(Global.player.play_time/10.0)
	if(Settings.world["mission_title"] != "challenge"):
		tokens_this_round *= Settings.world["points_scale"]
		
	tokens_this_round = int(tokens_this_round)
	
	print("Global.player.play_time", Global.player.play_time)
	if(Settings.world["points_scale"]  > 1.0 and Settings.world["mission_title"] != "challenge"):
		tokens_this_round = int(tokens_this_round * Settings.world["points_scale"])
		
	$PointAddPopup/TokensEarnedLabel.text = "Tokens Earned: " + str(tokens_this_round)
	Settings.shop["tokens"] += tokens_this_round
	
	Settings.save()
	$PointAddPopup.show()	
	$PointAddPopup/WaitTimer.start()

export var point_popup_wait_time = 2.0
func _on_RackingTimer_timeout():
	if(done_racking_points ):
		$PointAddPopup/RackingTimer.stop()
		$GameOverPopup/Buttons.is_active = true
	else:
		point_num1 -= int(points_this_round/14)
		point_num2 += int(points_this_round/14)
		$ButtonSelectAudio.play()
		var next_point_num1 = point_num1 - int(points_this_round/14)
		if(point_num1 * next_point_num1 <= 0): # they current and next have different signs
			point_num2 += point_num1
			point_num1 = 0
			done_racking_points = true
			$PointAddPopup/WaitTimer.start()
			
		$PointAddPopup/PointsLabel.text = "Points Earned: " + Global.point_num_to_string(point_num1)
		$PointAddPopup/TotalPointsLabel.text = "Total Points: " + Global.point_num_to_string(point_num2)

func _on_ShopButton_pressed():
	pass

func _on_ResumeButton_pressed():
	unpause()

func _on_OptionsButton_pressed():
	pass

func _on_PausePopupBufferTimer_timeout():
	can_unpause = true

func _on_WaitTimer_timeout():
	if(done_racking_points or points_this_round == 0):
		finish_racking()
	else:
		if(Settings.world["mission_title"] != "challenge"):
			$ButtonSelectAudio.pitch_scale *= Settings.world["points_scale"]/2
		$PointAddPopup/RackingTimer.start()

func finish_racking():
	$PointAddPopup/RackingTimer.stop()
	$PointAddPopup/WaitTimer.stop()

	is_racking_points = false
	done_racking_points = true
	if(return_to_menu_after_done_racking):
		return_to_menu()
	else:
		get_parent().find_node("MusicShuffler").volume_db += point_add_music_mod
		
		if(Settings.world["mission_title"] != "challenge"):
			$ButtonSelectAudio.pitch_scale /= Settings.world["points_scale"]/2
		$PointAddPopup.hide()
		$GameOverPopup.show()
		$GameOverPopup/Buttons.is_active = true
