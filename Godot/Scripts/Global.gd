extends Node

var player = null
var level_timer = null
var world = null

var target_frame_rate = 60.0
var points_this_round = 0

var version = "v1.0.2"
var play_time = 0.0

var main_menu_has_faded = false
var return_scene = "res://Scenes/MainScenes/MainMenu.tscn"
var ui_states = {}
var bullet_type_scenes = [load("res://Scenes/HelperScenes/Bullet.tscn"), load("res://Scenes/HelperScenes/Bullet2.tscn"), load("res://Scenes/HelperScenes/Bullet3.tscn"),load("res://Scenes/HelperScenes/Bullet4.tscn") ]
var player_type_scenes = [load("res://Scenes/MainScenes/PlayerType1.tscn"), load("res://Scenes/MainScenes/PlayerType2.tscn"), load("res://Scenes/MainScenes/PlayerType3.tscn"), load("res://Scenes/MainScenes/PlayerType4.tscn"), load("res://Scenes/MainScenes/PlayerType5.tscn")]

var shakes = {}
var partical_scales_per_graphical_setting = {"Min":0.1, "Low":0.3, "Mid":0.7, "High": 1.0, "Ultra":1.5}

func save_var(path, _var):
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_var(_var)
	file.close()

func load_var(path):
	var file = File.new()
	file.open(path, file.READ)
	var settings_from_file = file.get_var()
	file.close()
	return settings_from_file

func round_float(_float, decimal_num):
	return int( _float * pow(10, decimal_num) )/(pow(10, decimal_num))

func equal_with_x_precision(f1, f2, x):
	return int(f1 * pow(10, x)) == int(f2 * pow(10, x))

var suffix_nums = [1000000000.0, 1000000.0, 1000.0]
func point_num_to_string(point_num, suffixes=["b", "m", "k"]):
	for i in range(len(suffixes)):
		if(abs(point_num) > suffix_nums[i]):
			return str(round_float( point_num/suffix_nums[i], 3)) + suffixes[i]
	return str(point_num)

var last_full_screen = null
var time_left_vibrating = 0
func _process(delta):
	if(Settings.saved_settings["fullscreen_mode"] != last_full_screen):
		last_full_screen = Settings.saved_settings["fullscreen_mode"]
		OS.keep_screen_on = last_full_screen
	if(Input.is_action_just_pressed("fullscreen")):
		Settings.saved_settings["fullscreen_mode"] = !Settings.saved_settings["fullscreen_mode"]
		Settings.save()
		OS.window_fullscreen = Settings.saved_settings["fullscreen_mode"]
	
	if(time_left_vibrating < 0):
		time_left_vibrating = 0
		last_vibration_priority = 0
		vibration_is_happening = false
	else:
		time_left_vibrating -= delta

const VIB_DEVICE = 0
var last_vibration_priority = 0
var vibration_is_happening = false
func vibrate_controller(dur=0.5, weak_mag_mult=1.0, strong_mag_mult=1.0, priority=0):
	var start_new_vibration = false
	
	if(last_vibration_priority < priority):
		last_vibration_priority = priority
		start_new_vibration = true
	
	if(dur > time_left_vibrating):
		start_new_vibration = true
		
	if(start_new_vibration or (vibration_is_happening == false)):
		vibration_is_happening = true
		Input.stop_joy_vibration(VIB_DEVICE)
		Input.start_joy_vibration(VIB_DEVICE,weak_mag_mult, strong_mag_mult, dur)
		time_left_vibrating = dur
