extends CanvasLayer

var game_is_over = false
var can_unpause = false
var pause_audio_pitch_scale = 0.66
var is_pitching_music = false
var old_high_score =  HighScore.get_score(Settings.world["mission_title"])

var points_suffix = " s" if Settings.world["has_point_goal"] else ""
func _ready():
	if(Settings.get_setting_if_exists(Settings.player, "can_bomb", true) == false):
		$BombDisplay.visible = false

var is_racking_points = false
var is_showing_new_high_score = false

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
		
	if(is_showing_new_high_score  and Input.is_action_just_pressed("ui_cancel")):
		finish_showing_high_score()
			

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

var tokens_this_round
func game_over():
	get_parent().find_node("MusicShuffler").volume_db -= point_add_music_mod
	var is_mission = Settings.world["is_mission"]
	var mission_complete = false
	var mission_title = Settings.world["mission_title"]
	if(!is_mission):
		HighScore.record_score(Global.points_this_round, mission_title)
	else:
		if(Settings.world["has_point_goal"] and Settings.world["point_goal"] <= Global.points_this_round):
			HighScore.record_score(Global.round_float(Global.play_time, 3), mission_title, false)
			mission_complete = true
		if(Settings.world["has_time_goal"] and Settings.world["time_goal"] <= Global.play_time):
			HighScore.record_score(Global.points_this_round, mission_title, true)
			mission_complete = true
			
			
	tokens_this_round = default_token_reward
	print("Global.player.play_time, ", Global.player.play_time)
	tokens_this_round = int(Global.player.play_time/10.0)
	if(Settings.world["mission_title"] != "challenge"):
		tokens_this_round *= Settings.world["points_scale"]
		tokens_this_round = int(tokens_this_round)
	
	var made_new_high_score = false
	if(Settings.world["is_mission"]):
		if(mission_complete):
			if(Settings.world["has_point_goal"]):
				made_new_high_score = (old_high_score > Global.play_time) or (old_high_score == 0)
			else: # time goal
				old_high_score < Global.points_this_round
	else:
		made_new_high_score = old_high_score < Global.points_this_round
	
	print("high_score, ", old_high_score)
	print("Global.points_this_round, ", Global.points_this_round)
	$PausePopup.hide()	
	if(made_new_high_score):
		new_high_score_event()
	else:
		if(done_racking_points or Global.points_this_round == 0):
			return_to_menu()
		else:
			point_add_popup_event()
			
	print("Global.player.points, ", Global.player.points)
	$GameOverPopup/GameOverLabel.text = "COMPLETE" if is_mission and mission_complete else "GAME OVER"
	game_is_over = true

func new_high_score_event():
	if(Global.points_this_round <= 0):
		return
	is_showing_new_high_score = true
	$HighScorePopup/HighScoreLabel2.text = str(old_high_score) + points_suffix
	$HighScorePopup/HighScoreWaitTimer.start()
	$HighScorePopup.show()

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
	if(game_is_over):
		return_to_menu()
	else:
		return_to_menu_after_done_racking = true
		game_over()

var points_this_round
var point_num1
var point_num2
var point_add_music_mod = 10
var default_token_reward = 0
func point_add_popup_event():
	if(done_racking_points):
		return
	
	is_racking_points = true
	
	points_this_round = Global.points_this_round
	point_num1 = points_this_round
	point_num2 = Settings.shop["points"]
	Settings.shop["points"] += points_this_round
	
	$PointAddPopup/PointsLabel.text = "Points Earned: " + Global.point_num_to_string(points_this_round)
	$PointAddPopup/TotalPointsLabel.text = "Total Points: " + Global.point_num_to_string(Settings.shop["points"])
	
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


var high_score_timeout_count = 0
func _on_HighScoreWaitTimer_timeout():
	if(high_score_timeout_count == 0):
		$HighScorePopup/HighScoreLabel2.fade_out()
	if(high_score_timeout_count == 1):
		$HighScorePopup/HighScoreLabel.text = ":New High Score:"
		$HighScorePopup/HighScoreLabel2.fade_in()
		$HighScorePopup/AudioStreamPlayer.play()
		if(Settings.world["has_point_goal"]):
			$HighScorePopup/HighScoreLabel2.text = str(Global.play_time) + points_suffix
		else:
			$HighScorePopup/HighScoreLabel2.text = str(Global.points_this_round) + points_suffix
		$HighScorePopup/Particles2D.emitting = true

	if(high_score_timeout_count == 4):
		finish_showing_high_score()
		
	high_score_timeout_count += 1
	
func finish_showing_high_score():
	high_score_timeout_count = 0
	is_showing_new_high_score = false
	old_high_score = Global.points_this_round
	$HighScorePopup/HighScoreWaitTimer.stop()
	$HighScorePopup.hide()
	point_add_popup_event()
