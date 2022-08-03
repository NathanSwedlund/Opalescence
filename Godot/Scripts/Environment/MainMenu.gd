extends Node2D

var current_button_selection = 0
var is_shifting_button_selection = false
var current_shifting_index = 0
var target_button_selection
var button_selections
var modulated_button_selections

var is_fading_in = true
var is_fading_in_music = true
var target_music_db = 0
var current_music_db = -33
var target_player_scale
export var fade_speed = 1
export var music_fade_speed = 8

func _ready():
	update_mode_availability()
	$PointsLabel.text = "Points: " + str(Global.point_num_to_string(Settings.shop["points"], ["b", "m", "k"]))
	$TokensLabel.text = "Tokens: " + str(Global.point_num_to_string(Settings.shop["tokens"], ["b", "m", "k"]))
	$VersionLabel.text = Global.version
	
	is_fading_in = Settings.saved_settings["show_intro"] and !Global.main_menu_has_faded
	is_fading_in_music = Settings.saved_settings["show_intro"] and !Global.main_menu_has_faded
	target_music_db = Settings.saved_settings["music_volume"] + Settings.min_vol
	
	if(Settings.saved_settings["music_volume"] == 0):
		$MusicShuffler.volume_db = -80
		target_music_db = -80
		current_music_db = -80
	else:	
		$MusicShuffler.volume_db = current_music_db
	
	$MusicShuffler.play()
	reset()
	
func reset():
	if(is_fading_in):
		$PointFactory.is_active = false
		for c in $MenuCanvas.get_children():
			c.modulate.a = 0.0
		
		target_player_scale = $Player.scale
		$Player.modulate.a = 0.0
		$VersionLabel.modulate.a = 0.0
		$Player.scale = Vector2.ZERO
		$PointsLabel.modulate.a = 0.0
		$TokensLabel.modulate.a = 0.0
		
	else:
		$PointFactory.is_active = true
		Settings.apply_sound_settings()
		$MenuCanvas/OptionsSelection/FullscreenOption.update_selected(Settings.saved_settings["fullscreen_mode"], true, false)
		
		$MenuCanvas/OptionsSelection/PaleModeOption.update_selected(Settings.saved_settings["less_flashy_mode"], false, false)
		$MenuCanvas/OptionsSelection/ShowIntroOption.update_selected(Settings.saved_settings["show_intro"], false, false)
		$MenuCanvas/OptionsSelection/ShowWarningOption.update_selected(Settings.saved_settings["show_epilepsy_warning"], false, false)
		button_selections = [$MenuCanvas/MainSelection, $MenuCanvas/PlayModeSelection, $MenuCanvas/OptionsSelection, $MenuCanvas/StandardModesSelection, $MenuCanvas/ResetSelection, $MenuCanvas/ResetConfirmSelection]
		modulated_button_selections = [$MenuCanvas/MainSelection, $MenuCanvas/PlayModeSelection, $MenuCanvas/OptionsSelection, $MenuCanvas/StandardModesSelection,]
		shift_button_selection(Settings.current_main_menu_button_selection, false)
		$MenuCanvas/OptionsSelection/MusicVolumeOption.update_current_val(Settings.saved_settings["music_volume"])
		$MenuCanvas/OptionsSelection/SFXVolumeOption.update_current_val(Settings.saved_settings["fx_volume"])
		$MenuCanvas/OptionsSelection/ScreenShakeScaleOption.update_current_val(Settings.saved_settings["screen_shake_scale"])
		$MusicShuffler.volume_db = -80
		
func _on_ChallengeButton_pressed():
	Settings.current_main_menu_button_selection = current_button_selection
	get_tree().change_scene("res://Scenes/HelperScenes/UI/ChallengePage.tscn")

var last_color = Color.white
func _process(_delta):
	if(Input.is_action_just_pressed("fullscreen")):
		$UpdateFulscreenButtonTimer.start()
	
	if(target_music_db != current_music_db):
		target_music_db = Settings.saved_settings["music_volume"]/3 + Settings.min_vol	
		current_music_db = move_toward(current_music_db, target_music_db, _delta * music_fade_speed)
		$MusicShuffler.volume_db = current_music_db
		
	if(is_fading_in):
		fade_speed *= 1.02
		$Player.scale.y = move_toward($Player.scale.y, target_player_scale.y, fade_speed*_delta)
		$Player.scale.x = move_toward($Player.scale.x, target_player_scale.x, fade_speed*_delta)
		$Player.modulate.a = move_toward($Player.modulate.a, 1.0, fade_speed*_delta)
		$VersionLabel.modulate.a = move_toward($VersionLabel.modulate.a, 1.0, fade_speed*_delta)
		$PointsLabel.modulate.a =  move_toward($PointsLabel.modulate.a, 1.0, fade_speed*_delta)
		$TokensLabel.modulate.a =  move_toward($TokensLabel.modulate.a, 1.0, fade_speed*_delta)
		for c in $MenuCanvas.get_children():
			c.modulate.a =  move_toward(c.modulate.a, 1.0, fade_speed*_delta)
			
		if($Player.modulate.a >= 1.0):
			is_fading_in = false
			reset()
			Global.main_menu_has_faded = true
			Settings.apply_sound_settings()
			$PointFactory.is_active = true
	else:
		if($Player.modulate != last_color):
			var new_color = $Player.modulate
			$LabelContainer/OpalescenceLabel.modulate = new_color
			for button_selection in modulated_button_selections:
				button_selection.modulate = new_color
				for b in button_selection.get_children():
					b.get_node("Light2D").color = new_color
					
			$VersionLabel.modulate = new_color
			$PointsLabel.modulate = new_color
			$TokensLabel.modulate = new_color
			
			last_color = new_color

		if(Input.is_action_just_pressed("ui_cancel") and is_shifting_button_selection == false):
			if(current_button_selection == 2):
				Settings.save()
				shift_button_selection(0)
			if(current_button_selection == 1):
				shift_button_selection(0)
			if(current_button_selection == 3):
				shift_button_selection(1)
			if(current_button_selection == 4):
				shift_button_selection(2)
				$ResetPopup.hide()
			if(current_button_selection == 5):
				_on_NoButton_pressed()
				

func _on_QuitButton_pressed():
	get_tree().quit()

func _on_ArcadeButton_pressed():
	Settings.current_main_menu_button_selection = current_button_selection
	get_tree().change_scene("res://Scenes/HelperScenes/UI/MissionPage.tscn")

func _on_TutorialsButton_pressed():
	Settings.current_main_menu_button_selection = current_button_selection
	get_tree().change_scene("res://Scenes/HelperScenes/UI/TutorialsMissionPage.tscn")

func toggle_button_selection():
	$ButtonShiftTimer.start()

func _on_PlayButton_pressed():
	if($MenuCanvas/MainSelection.is_active == false or is_fading_in):
		return 
	shift_button_selection(1)

func _on_BackButton_pressed():
	if($MenuCanvas/PlayModeSelection.is_active == false or is_fading_in):
		return 
	shift_button_selection(0)

func _on_StandardButton_pressed():
	if($MenuCanvas/PlayModeSelection.is_active == false or is_fading_in):
		return 
	shift_button_selection(3)

var play_shift_audio = true
func shift_button_selection(button_selection_num, _play_shift_audio=true):
	if(is_fading_in):
		return
	play_shift_audio = _play_shift_audio
#	if(button_selection_num != current_button_selection):
	target_button_selection = button_selection_num
	is_shifting_button_selection = true
	current_shifting_index = 0
	$ButtonShiftTimer.start()
	button_selections[current_button_selection].is_active = false

func _on_ButtonShiftTimer_timeout():
	var shifted_any = false
	for c in button_selections[current_button_selection].get_children():
		if(has_meta("shift_index")):
			if(c.button_shift_index == current_shifting_index):
				c.visible = false
				shifted_any = true
		else:
			if(c.button_index == current_shifting_index):
				c.visible = false
				shifted_any = true

	for c in button_selections[target_button_selection].get_children():
		if(has_meta("shift_index")):
			if(c.button_shift_index == current_shifting_index):
				c.visible = true
				shifted_any = true
		else:
			if(c.button_index == current_shifting_index):
				c.visible = true
				shifted_any = true

	if(shifted_any):
		if(play_shift_audio):
			$ButtonShiftAudio.play()
		current_shifting_index += 1
	else:
		button_selections[target_button_selection].is_active = true
		current_button_selection = target_button_selection
		current_shifting_index = 0
		is_shifting_button_selection = false
		$ButtonShiftTimer.stop()
		play_shift_audio = true


func update_mode_availability():
	var standard_mode_buttons = $MenuCanvas/StandardModesSelection.get_child_count()
	if(Settings.shop["hard_mode_unlocked"] == false):
		standard_mode_buttons -= 1
		$MenuCanvas/StandardModesSelection/HardButton.queue_free()
	if(Settings.shop["extra_hard_mode_unlocked"] == false):
		standard_mode_buttons -= 1
		$MenuCanvas/StandardModesSelection/ExtraHardButton.queue_free()
	if(Settings.shop["nightmare_mode_unlocked"] == false):
		standard_mode_buttons -= 1
		$MenuCanvas/StandardModesSelection/NightmareMode.queue_free()
	
		
	$MenuCanvas/StandardModesSelection.button_count = standard_mode_buttons
	
	var button_ind = 0
	for b in $MenuCanvas/StandardModesSelection.get_children():
		if(b.is_queued_for_deletion() == false):
			b.button_shift_index = button_ind
			b.button_index = button_ind
			button_ind += 1
			
	
		
	if(Settings.shop["challenge_mode_unlocked"] == false):
		$MenuCanvas/PlayModeSelection/ChallengeButton.queue_free()
		$MenuCanvas/PlayModeSelection.button_count -= 1
		$MenuCanvas/PlayModeSelection/BackButton.button_index -= 1
		$MenuCanvas/PlayModeSelection/BackButton.button_shift_index -= 1
		
func _on_StorePage_pressed():
	if($MenuCanvas/MainSelection.is_active == false or is_fading_in):
		return 

	Settings.current_main_menu_button_selection = 0
	Global.return_scene = "res://Scenes/MainScenes/MainMenu.tscn"
	get_tree().change_scene("res://Scenes/MainScenes/StorePage.tscn")

func _on_OptionsButton_pressed():
	if($MenuCanvas/MainSelection.is_active == false or is_fading_in):
		return 

	shift_button_selection(2)

func _on_OptionBackButton_pressed():
	Settings.save()
	shift_button_selection(0)

func _on_MusicVolumeOption_pressed(_value):
	Settings.saved_settings["music_volume"] = _value
	Settings.apply_sound_settings()

func _on_SFXVolumeOption_pressed(_value):
	Settings.saved_settings["fx_volume"] = _value
	Settings.apply_sound_settings()

func _on_PaleModeOption_pressed(is_selected):
	Settings.saved_settings["less_flashy_mode"] = is_selected
	Settings.reset_colors()

func _on_FullscreenOption_pressed(is_selected):
	Settings.saved_settings["fullscreen_mode"] = is_selected
	OS.window_fullscreen = is_selected

func _on_ShowIntroOption_pressed(is_selected):
	Settings.saved_settings["show_intro"] = is_selected

func _on_ShowWarningOption_pressed(is_selected):
	Settings.saved_settings["show_epilepsy_warning"] = is_selected

export var standard_diff_settings = {
	"ExtraEasy":{
		"is_mission":false,
		"mission_title":"ExtraEasyStandard",
		"powerup_time_max":7,
		"points_scale":0.2,
		"starting_health":5,
		"enemy_health_scale":1.0,
		"enemy_time_max":1.0,
		"enemy_time_min":0.8,
		"light_scale":2.5,
		"shooter_shoot_speed_scale":1.0,
	},
	"Easy":{
		"powerup_time_max":12,
		"is_mission":false,
		"mission_title":"EasyStandard",
		"points_scale":0.5,
		"starting_health":4,
		"enemy_health_scale":1.0,
		"enemy_time_max":0.9,
		"enemy_time_min":0.7,
		"light_scale":2.0,
		"shooter_shoot_speed_scale":0.8,
	},
	"Medium":{
		"powerup_time_max":14,
		"is_mission":false,
		"mission_title":"MediumStandard",
		"points_scale":1.0,
		"starting_health":3,
		"enemy_health_scale":1.8,
		"enemy_time_max":0.8,
		"enemy_time_min":0.5,
		"light_scale":1.6,
		"chaser_min_scale":0.15,
		"shooter_shoot_speed_scale":0.65,
	},
	"Hard":{
		"powerup_time_max":15,
		"is_mission":false,
		"mission_title":"HardStandard",
		"points_scale":1.5,
		"starting_health":2,
		"enemy_health_scale":2.5,
		"enemy_time_max":0.7,
		"enemy_time_min":0.5,
		"light_scale":1.4,
		"shrink_scale":0.95,
		"chaser_min_scale":0.15,
		"shooter_shoot_speed_scale":0.45,
	},
	"ExtraHard":{
		"powerup_time_max":18,
		"is_mission":false,
		"mission_title":"ExtraHardStandard",
		"points_scale":2.0,
		"starting_health":2,
		"enemy_health_scale":4,
		"enemy_time_max":0.4,
		"enemy_time_min":0.2,
		"light_scale":1.0,
		"shrink_scale":0.88,
		"chaser_min_scale":0.15,
		"chaser_max_scale":0.5,
		"shooter_missile_speed_scale":1.5,
		"shooter_shoot_speed_scale":0.3,
	},
	"Nightmare":{
		"powerup_time_max":20,
		"is_mission":false,
		"mission_title":"NightmareStandard",
		"points_scale":4.0,
		"starting_health":1,
		"enemy_health_scale":6,
		"enemy_time_max":0.25,
		"enemy_time_min":0.1,
		"light_scale":0.7,
		"min_scale":0.2,
		"shrink_scale":0.9,
		"chaser_min_scale":0.15,
		"chaser_max_scale":0.35,
		"shooter_missile_speed_scale":1.8,
		"shooter_shoot_speed_scale":0.1,
	},
}

func _on_ExtraEasyButton_pressed():
	if($MenuCanvas/StandardModesSelection.is_active == false or is_fading_in):
		return 
		
	Settings.reset_settings()
	load_standard(standard_diff_settings["ExtraEasy"])
	
func _on_EasyButton2_pressed():
	if($MenuCanvas/StandardModesSelection.is_active == false or is_fading_in):
		return 
		
	Settings.reset_settings()
	load_standard(standard_diff_settings["Easy"])

func _on_MediumButton_pressed():
	if($MenuCanvas/StandardModesSelection.is_active == false or is_fading_in):
		return 
		
	Settings.reset_settings()
	load_standard(standard_diff_settings["Medium"])

func _on_HardButton_pressed():
	if($MenuCanvas/StandardModesSelection.is_active == false or is_fading_in):
		return 
		
	Settings.reset_settings()
	load_standard(standard_diff_settings["Hard"])

func _on_ExtraHardButton_pressed():
	if($MenuCanvas/StandardModesSelection.is_active == false or is_fading_in):
		return 
	Settings.reset_settings()
	load_standard(standard_diff_settings["ExtraHard"])

func _on_NightmareMode_pressed():
	if($MenuCanvas/StandardModesSelection.is_active == false or is_fading_in):
		return 
	Settings.reset_settings()
	load_standard(standard_diff_settings["Nightmare"])
	
func load_standard(settings):
	Settings.current_main_menu_button_selection = 3
	Settings.change_settings(settings)
	Global.return_scene = "res://Scenes/MainScenes/MainMenu.tscn"
	get_tree().change_scene("res://Scenes/MainScenes/World.tscn")

func _on_CustomizeButton_pressed():
	Settings.current_main_menu_button_selection = 0
	get_tree().change_scene("res://Scenes/MainScenes/CustomizePage.tscn")

func _on_ScreenShakeScaleOption_pressed(_value):
	Settings.saved_settings["screen_shake_scale"] = _value



func _on_StandardBackButton_pressed():
	if($MenuCanvas/StandardModesSelection.is_active == false or is_fading_in):
		return
	shift_button_selection(1)



func _on_UpdateFulscreenButtonTimer_timeout():
	$MenuCanvas/OptionsSelection/FullscreenOption.update_selected(Settings.saved_settings["fullscreen_mode"], false, false)


func _on_ResetSettingsButton_pressed():
	Settings.reset_settings()
	Settings.saved_settings = Settings.saved_settings_default.duplicate()
	Settings.reset_colors()
	update()
	shift_button_selection(0)
	
	Settings.save()
	get_tree().change_scene("res://Scenes/MainScenes/OpeningScene.tscn")

func _on_ResetAllContentButton_pressed():
	$ResetConfirmPopup.show()
	$ResetPopup.hide()
	shift_button_selection(5)

func reset_all_content():
	HighScore.reset_high_scores()
	Settings.reset_settings()
	Settings.saved_settings = Settings.saved_settings_default.duplicate()
	Settings.reset_colors()
	Settings.shop = Settings.shop_default.duplicate()
	
	Settings.save()
	get_tree().change_scene("res://Scenes/MainScenes/OpeningScene.tscn")

func _on_CancelResetButton_pressed():
	shift_button_selection(2)
	$ResetPopup.hide()

func _on_ResetButton_pressed():
	shift_button_selection(4)
	$ResetPopup.show()

func _on_NoButton_pressed():
	$ResetPopup.show()
	$ResetConfirmPopup.hide()
	shift_button_selection(4)

func _on_YesButton_pressed():
	reset_all_content()


func _on_ResetHighScoreButton_pressed():
	HighScore.reset_high_scores()
	HighScore.save_high_scores()
	get_tree().change_scene("res://Scenes/MainScenes/OpeningScene.tscn")
