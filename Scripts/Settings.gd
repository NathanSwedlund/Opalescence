extends Node

var save_data = {}

var default_colors = [Color.red, Color.orange, Color.yellow, Color.green, Color.cadetblue, Color.lightblue, Color.pink]

var saved_settings_default = {
	"fx_volume":10,
	"music_volume":10,
	"less_flashy_mode":false,
	"colors":null
}
var saved_settings = saved_settings_default.duplicate()

var world_default = {
	"is_mission":false,
	"mission_title":"MISSION TITLE",
	"has_point_goal":false,
	"point_goal":0.0,
	"time_goal":0.0,
	"has_time_goal":false,
	"left_bound":10,
	"right_bound":1014,
	"up_bound":10,
	"down_bound":590,
	"points_scale":1.0,
}
var world = world_default.duplicate()

var factory_default = {
	"point_is_active":true,
	"point_time_min":0.1,
	"point_time_max":0.8,


	"enemy_is_active":true,
	"enemy_time_min":3,
	"enemy_time_max":4,
	"enemy_spawn_away_radius":200,
	"enemy_blocker_prob":0.05,
	"enemy_chaser_prob":0.8,
	"enemy_comet_prob":0.0,
	"enemy_shooter_prob":0.1,

	"powerup_is_active":true,
	"powerup_time_min":10,
	"powerup_time_max":15,
	"powerup_barrage_prob":1,
	"powerup_bomb_up_prob":2,
	"powerup_bombastic_prob":1,
	"powerup_bulet_time_prob":1,
	"powerup_gravity_well_prob":1,
	"powerup_incendiary_prob":1,
	"powerup_max_bomb_prob":0.5,
	"powerup_max_up_prob":0.0,
	"powerup_one_up_prob":0.2,
	"powerup_opalescence_prob":0.5,
	"powerup_oversheild_prob":0.9,
	"powerup_unmaker_prob":1,
	"powerup_vision_prob":1,
}
var factory = factory_default.duplicate()

var enemy_default = {
	"enemy_health_scale":1.0,
	
	"chaser_gen_scale":1.0,
	"chaser_min_scale":0.15,
	"chaser_max_scale":1.0,
	"chaser_base_health":10,
	"chaser_point_reward":400,

	"shooter_gen_scale":1.0,
	"shooter_shoot_freq_range": [1.0, 2.0],
	"shooter_point_reward":600,
	"shooter_health":15,
	"shooter_missile_speed":400,
	"shooter_missile_speed_scale":1.0,
	"shooter_missile_health":1,
	"shooter_missile_damage":5,

	"blocker_gen_scale":1.0,
	"blocker_point_reward":1250,
	"blocker_health":100,
}
var enemy = enemy_default.duplicate()

var player_default = {
	"speed":480.0,
	"player_speed_scale":1.0,
	"starting_health":3,
	"shrink_scalar":0.95,
	"min_scale":0.5,
	"gravity_radius":100.0,
	"gravity_pull_scale":1.0,
	"default_bullets_burst_wait_time":0.1,
	"is_active":true,
	"can_bomb":true,
	"starting_bombs":3,
	"powerup_point_value":1000,
	"opalescence_shift_speed":0.7,
	"opalescence_shift_speed_less_flashy":0.1,
	"bullet_time_time_scale":0.2,
	"vision_light_scale":3,
	"gravity_well_pull_scale":6.0,
	"gravity_well_radius":100000,
	"barrage_burst_time":0.04,
	"unmaker_scale":2.3,
	"can_shoot":true,
	"default_bullets_per_burst":3,
	"can_shoot_laser":true,
}

var player = player_default.duplicate()
var saved_settings_path = "user://settings.dat"
var save_path = "user://save.dat"

var current_main_menu_button_selection = 0

func _ready():
	saved_settings["colors"] = default_colors
	var saved_settings_from_file = Global.load_var(saved_settings_path)
	if(saved_settings_from_file == null):
		saved_settings = saved_settings_default
	else:
		saved_settings = saved_settings_from_file
	reset_colors()
	
func save_settings():
	Global.save_var(saved_settings_path, saved_settings)
	
func reset_colors():
	saved_settings["colors"] = default_colors.duplicate()
	if(saved_settings["less_flashy_mode"]):
		for c in range(len(saved_settings["colors"])):
			saved_settings["colors"][c].r = move_toward(saved_settings["colors"][c].r, 1.0, 0.5)
			saved_settings["colors"][c].g = move_toward(saved_settings["colors"][c].g, 1.0, 0.5)
			saved_settings["colors"][c].b = move_toward(saved_settings["colors"][c].b, 1.0, 0.5)

#	print("saved_settings[\"colors\"], ", saved_settings["colors"])
	
func get_setting_if_exists(setting_var, _name, _var):
	if((_name in setting_var.keys() ) == false):
		return _var
	if(setting_var[_name] == null):
		return _var
	else: # is a valid setting and is not null
		return setting_var[_name]

func reset_settings():
	world = world_default.duplicate()
	player = player_default.duplicate()
	enemy = enemy_default.duplicate()
	factory = factory_default.duplicate()
	
#func _process(delta):
#	print(saved_settings["less_flashy_mode"])
	
var min_vol = -20
var max_vol = 10
func apply_sound_settings():
	for c in get_tree().get_nodes_in_group("Music"):
		if(Settings.saved_settings["music_volume"] == 0):
			c.volume_db = -80
		else:
			c.volume_db = Settings.saved_settings["music_volume"] + min_vol
	for c in get_tree().get_nodes_in_group("FX"):
		if(Settings.saved_settings["fx_volume"] == 0):
			c.volume_db = -80
		else:
			c.volume_db = Settings.saved_settings["fx_volume"] + min_vol
