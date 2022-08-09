extends Node

var player = null
var level_timer = null
var world = null

var target_frame_rate = 60.0
var points_this_round = 0

var version = "v1.2.3"
var play_time = 0.0

var main_menu_has_faded = false
var return_scene = "res://Scenes/MainScenes/MainMenu.tscn"
var ui_states = {}
var bullet_type_scenes = [load("res://Scenes/HelperScenes/Bullet.tscn"), load("res://Scenes/HelperScenes/Bullet2.tscn"), load("res://Scenes/HelperScenes/Bullet3.tscn"),load("res://Scenes/HelperScenes/Bullet4.tscn"), load("res://Scenes/HelperScenes/Bullet5.tscn") ]
var laser_type_scenes = [load("res://Scenes/HelperScenes/Laser.tscn"), load("res://Scenes/HelperScenes/Laser2.tscn"), load("res://Scenes/HelperScenes/Laser3.tscn"), load("res://Scenes/HelperScenes/Laser4.tscn")]
var laser_type_charge_times = [1.5, 1.5, 3.0, 2.0]
var player_type_scenes = [load("res://Scenes/MainScenes/PlayerType1.tscn"), load("res://Scenes/MainScenes/PlayerType2.tscn"), load("res://Scenes/MainScenes/PlayerType3.tscn"), load("res://Scenes/MainScenes/PlayerType4.tscn"), load("res://Scenes/MainScenes/PlayerType5.tscn")]
var entity_effects = {}
var shakes = {}
var partical_scales_per_graphical_setting = {"Min":0.2, "Low":0.3, "Mid":0.8, "High": 1.0, "Ultra":1.5}

func _ready():
	pause_mode = PAUSE_MODE_PROCESS

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
var seconds_per_status_effect_calc = 0.3
var seconds_since_last_status_effect_calc = 0.0
var poison_damage = 1
var seconds_since_last_enemy_explosion_sound = 0.0
func _process(delta):
	seconds_since_last_enemy_explosion_sound += delta
	if(Settings.saved_settings["fullscreen_mode"] != last_full_screen):
		last_full_screen = Settings.saved_settings["fullscreen_mode"]
		OS.keep_screen_on = last_full_screen
	if(Input.is_action_just_pressed("fullscreen")):
		Settings.saved_settings["fullscreen_mode"] = !Settings.saved_settings["fullscreen_mode"]
		Settings.save()
		OS.window_fullscreen = Settings.saved_settings["fullscreen_mode"]
	
	if(get_tree().paused == false):
		if(time_left_vibrating < 0):
			time_left_vibrating = 0
			last_vibration_priority = 0
			vibration_is_happening = false
		else:
			time_left_vibrating -= delta
		
		var left_stick_direction = Input.get_action_strength("controller_left_stick_down") - Input.get_action_strength("controller_left_stick_up")
		if(left_stick_direction != 0):
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
			
		seconds_since_last_status_effect_calc += delta
		if(seconds_since_last_status_effect_calc >= seconds_per_status_effect_calc):
			seconds_since_last_status_effect_calc = 0.0
			for key in entity_effects.keys():
				if(is_instance_valid(key)):
					if(entity_effects[key].has("poison_level")):
						key.take_damage(poison_damage*entity_effects[key]["poison_level"])
				else:
					entity_effects.erase(key)
	

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
		
	
func increase_status_leve(entity, status_name, increase_amount=1):
	if(entity_effects.has(entity) == false):
		entity_effects[entity] = {}
		
	if(entity_effects[entity].has(status_name) == false):
		entity_effects[entity][status_name] = 0
		
	entity_effects[entity][status_name] += increase_amount
		
func _input(event):
	if (event is InputEventMouseMotion):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
