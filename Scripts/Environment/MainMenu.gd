extends Node2D

var current_button_selection = 0
var is_shifting_button_selection = false
var current_shifting_index = 0
var target_button_selection
var button_selections

var is_fading_in = true
var is_fading_in_music = true
var target_music_db = 0
var current_music_db = -40
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
		$MusicShuffler.stop()
		
	reset()
	$MusicShuffler.volume_db = current_music_db
	$MusicShuffler.play()
	
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
		
	else:
		$PointFactory.is_active = true
		Settings.apply_sound_settings()
		$MenuCanvas/ButtonSelectionController3/FullscreenOption.update_selected(Settings.saved_settings["fullscreen_mode"], true, false)
		
		$MenuCanvas/ButtonSelectionController3/PaleModeOption.update_selected(Settings.saved_settings["less_flashy_mode"], false, false)
		$MenuCanvas/ButtonSelectionController3/ShowIntroOption.update_selected(Settings.saved_settings["show_intro"], false, false)
		$MenuCanvas/ButtonSelectionController3/ShowWarningOption.update_selected(Settings.saved_settings["show_epilepsy_warning"], false, false)
		button_selections = [$MenuCanvas/ButtonSelectionController1, $MenuCanvas/ButtonSelectionController2, $MenuCanvas/ButtonSelectionController3, $MenuCanvas/ButtonSelectionController4,]
		shift_button_selection(Settings.current_main_menu_button_selection, false)
		$MenuCanvas/ButtonSelectionController3/MusicVolumeOption.update_current_val(Settings.saved_settings["music_volume"])
		$MenuCanvas/ButtonSelectionController3/SFXVolumeOption.update_current_val(Settings.saved_settings["fx_volume"])
		
		$MusicShuffler.volume_db = -80
		
func _on_ChallengeButton_pressed():
	Settings.current_main_menu_button_selection = current_button_selection
	get_tree().change_scene("res://Scenes/HelperScenes/UI/ChallengePage.tscn")

var last_color = Color.white
func _process(_delta):
	if(target_music_db != current_music_db):
		target_music_db = Settings.saved_settings["music_volume"] + Settings.min_vol	
		current_music_db = move_toward(current_music_db, target_music_db, _delta * music_fade_speed)
		$MusicShuffler.volume_db = current_music_db
		
	if(is_fading_in):
		$Player.scale.y = move_toward($Player.scale.y, target_player_scale.y, fade_speed*_delta)
		$Player.scale.x = move_toward($Player.scale.x, target_player_scale.x, fade_speed*_delta)
		$Player.modulate.a = move_toward($Player.modulate.a, 1.0, fade_speed*_delta)
		$VersionLabel.modulate.a = move_toward($VersionLabel.modulate.a, 1.0, fade_speed*_delta)
		$PointsLabel.modulate.a =  move_toward($PointsLabel.modulate.a, 1.0, fade_speed*_delta)
		$TokensLabel.modulate.a =  move_toward($TokensLabel.modulate.a, 1.0, fade_speed*_delta)
		for c in $MenuCanvas.get_children():
			c.modulate.a =  move_toward(c.modulate.a, 1.0, fade_speed*_delta)
			
		if($Player.modulate.a == 1.0):
			is_fading_in = false
			reset()
			Global.main_menu_has_faded = true
			$PointFactory.is_active = true
	else:
		if($Player.modulate != last_color):
			var new_color = $Player.modulate
			$LabelContainer/OpalescenceLabel.modulate = new_color
			for button_selection in button_selections:
				button_selection.modulate = new_color

			$VersionLabel.modulate = new_color
			$PointsLabel.modulate = new_color
			$TokensLabel.modulate = new_color
		
			for c in $MenuCanvas/ButtonSelectionController1.get_children():
				c.get_node("Light2D").color = new_color
			for c in $MenuCanvas/ButtonSelectionController2.get_children():
				c.get_node("Light2D").color = new_color
			
			
			
			last_color = new_color

		if(Input.is_action_just_pressed("ui_cancel")):
			if(current_button_selection == 2):
				Settings.save()
			if(current_button_selection != 0):
				shift_button_selection(0)
				

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
	shift_button_selection(1)

func _on_BackButton_pressed():
	shift_button_selection(0)

func _on_StandardButton_pressed():
	shift_button_selection(3)

var play_shift_audio = true
func shift_button_selection(button_selection_num, _play_shift_audio=true):
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
	var standard_index_mod = 0
	if(Settings.shop["hard_mode_unlocked"] == false):
		$MenuCanvas/ButtonSelectionController4/HardButton.queue_free()
		standard_index_mod += 1
	if(Settings.shop["extra_hard_mode_unlocked"] == false):
		$MenuCanvas/ButtonSelectionController4/ExtraHardButton.queue_free()
		standard_index_mod += 1
	if(Settings.shop["nightmare_mode_unlocked"] == false):
		$MenuCanvas/ButtonSelectionController4/NightmareMode.queue_free()
		standard_index_mod += 1
		
	print(Settings.shop)
	print("\n backButton ind ", $MenuCanvas/ButtonSelectionController4/BackButton.button_index)
	
	if($MenuCanvas/ButtonSelectionController4.find_node("HardButton")):
		$MenuCanvas/ButtonSelectionController4/HardButton.button_index -= standard_index_mod
		$MenuCanvas/ButtonSelectionController4/HardButton.button_shift_index -= standard_index_mod
	if($MenuCanvas/ButtonSelectionController4.find_node("ExtraHardButton")):
		$MenuCanvas/ButtonSelectionController4/ExtraHardButton.button_index -= standard_index_mod
		$MenuCanvas/ButtonSelectionController4/ExtraHardButton.button_shift_index -= standard_index_mod
	if($MenuCanvas/ButtonSelectionController4.find_node("NightmareMode")):
		$MenuCanvas/ButtonSelectionController4/NightmareMode.button_index -= standard_index_mod
		$MenuCanvas/ButtonSelectionController4/NightmareMode.button_shift_index -= standard_index_mod
	
	$MenuCanvas/ButtonSelectionController4/BackButton.button_index -= standard_index_mod
	$MenuCanvas/ButtonSelectionController4/BackButton.button_shift_index -= standard_index_mod
	$MenuCanvas/ButtonSelectionController4.button_count -= standard_index_mod
	
	print("\n backButton ind ", $MenuCanvas/ButtonSelectionController4/BackButton.button_index)
	
	if(Settings.shop["challenge_mode_unlocked"] == false):
		$MenuCanvas/ButtonSelectionController2/ChallengeButton.queue_free()
		$MenuCanvas/ButtonSelectionController2.button_count -= 1
		$MenuCanvas/ButtonSelectionController2/BackButton.button_index -= 1
		$MenuCanvas/ButtonSelectionController2/BackButton.button_shift_index -= 1
		
func _on_StorePage_pressed():
	Settings.current_main_menu_button_selection = 0
	Global.return_scene = "res://Scenes/MainScenes/MainMenu.tscn"
	get_tree().change_scene("res://Scenes/MainScenes/StorePage.tscn")

func _on_OptionsButton_pressed():
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
		"points_scale":0.25,
		"starting_health":5,
		"enemy_health_scale":1.0,
		"enemy_time_max":4.0,
		"enemy_time_min":2.0,
		"light_scale":1.6,
	},
	"Easy":{
		"is_mission":false,
		"mission_title":"EasyStandard",
		"points_scale":0.5,
		"starting_health":4,
		"enemy_health_scale":0.8,
		"enemy_time_max":4.0,
		"enemy_time_min":2.0,
		"light_scale":1.3,
	},
	"Medium":{
		"is_mission":false,
		"mission_title":"MediumStandard",
		"points_scale":1.0,
		"starting_health":3,
		"enemy_health_scale":1.8,
		"enemy_time_max":2.0,
		"enemy_time_min":1.0,
		"light_scale":1,
		"chaser_min_scale":0.15,
	},
	"Hard":{
		"is_mission":false,
		"mission_title":"HardStandard",
		"points_scale":2.0,
		"starting_health":2,
		"enemy_health_scale":2.5,
		"enemy_time_max":0.9,
		"enemy_time_min":0.4,
		"light_scale":0.75,
		"shrink_scale":0.95,
		"chaser_min_scale":0.15,
	},
	"ExtraHard":{
		"is_mission":false,
		"mission_title":"ExtraHardStandard",
		"points_scale":4.0,
		"starting_health":2,
		"enemy_health_scale":4,
		"enemy_time_max":0.5,
		"enemy_time_min":0.4,
		"light_scale":0.5,
		"shrink_scale":0.88,
		"chaser_min_scale":0.15,
		"chaser_max_scale":0.5,
		"shooter_missile_speed_scale":1.5,
	},
	"Nightmare":{
		"is_mission":false,
		"mission_title":"ExtraHardStandard",
		"points_scale":6.0,
		"starting_health":1,
		"enemy_health_scale":6,
		"enemy_time_max":0.3,
		"enemy_time_min":0.3,
		"light_scale":0.3,
		"shrink_scale":0.9,
		"chaser_min_scale":0.15,
		"chaser_max_scale":0.35,
		"shooter_missile_speed_scale":1.8,
	},
}

func _on_ExtraEasyButton_pressed():
	Settings.reset_settings()
	load_standard(standard_diff_settings["ExtraEasy"])
	
func _on_EasyButton2_pressed():
	Settings.reset_settings()
	load_standard(standard_diff_settings["Easy"])

func _on_MediumButton_pressed():
	Settings.reset_settings()
	load_standard(standard_diff_settings["Medium"])

func _on_HardButton_pressed():
	Settings.reset_settings()
	load_standard(standard_diff_settings["Hard"])

func _on_ExtraHardButton_pressed():
	Settings.reset_settings()
	load_standard(standard_diff_settings["ExtraHard"])

func _on_NightmareMode_pressed():
	Settings.reset_settings()
	load_standard(standard_diff_settings["Nightmare"])
	
func load_standard(settings):
	Settings.current_main_menu_button_selection = 3
	Settings.change_settings(settings)
	Global.return_scene = "res://Scenes/MainScenes/MainMenu.tscn"
	get_tree().change_scene("res://Scenes/MainScenes/World.tscn")

func _on_CustomizeButton_pressed():
	get_tree().change_scene("res://Scenes/MainScenes/CustomizePage.tscn")

