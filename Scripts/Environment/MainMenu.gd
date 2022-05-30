extends Node2D

var current_button_selection = 0
var is_shifting_button_selection = false
var current_shifting_index = 0
var target_button_selection
var button_selections

func _ready():
	Settings.apply_sound_settings()

	$MenuCanvas/ButtonSelectionController3/PaleModeOption.update_selected(Settings.saved_settings["less_flashy_mode"], false, false)
	$MenuCanvas/ButtonSelectionController3/FullscreenOption.update_selected(Settings.saved_settings["fullscreen_mode"], false, false)
	button_selections = [$MenuCanvas/ButtonSelectionController1, $MenuCanvas/ButtonSelectionController2, $MenuCanvas/ButtonSelectionController3]
	$MenuCanvas/ButtonSelectionController3/MusicVolumeOption.update_current_val(Settings.saved_settings["music_volume"])
	$MenuCanvas/ButtonSelectionController3/SFXVolumeOption.update_current_val(Settings.saved_settings["fx_volume"])
	shift_button_selection(Settings.current_main_menu_button_selection, false)

func _on_ChallengeButton_pressed():
	Settings.current_main_menu_button_selection = current_button_selection
	get_tree().change_scene("res://Scenes/HelperScenes/UI/ChallengePage.tscn")

var last_color = Color.white
func _process(_delta):
	if($Player.modulate != last_color):
		last_color = $Player.modulate
		$MenuCanvas/OpalescenceLabel.modulate = last_color
		$MenuCanvas/ButtonSelectionController1.modulate = last_color
		$MenuCanvas/ButtonSelectionController2.modulate = last_color
		$MenuCanvas/ButtonSelectionController3.modulate = last_color
		for c in $MenuCanvas/ButtonSelectionController1.get_children():
			c.get_node("Light2D").color = last_color
		for c in $MenuCanvas/ButtonSelectionController2.get_children():
			c.get_node("Light2D").color = last_color

	if(Input.is_action_just_pressed("ui_cancel")):
		if(current_button_selection == 2):
			Settings.save_settings()
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
	Settings.reset_settings()
	Settings.world["mission_title"] = "standard"
	get_tree().change_scene("res://Scenes/MainScenes/World.tscn")

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

func _on_OptionsButton_pressed():
	shift_button_selection(2)

func _on_OptionBackButton_pressed():
	Settings.save_settings()
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
