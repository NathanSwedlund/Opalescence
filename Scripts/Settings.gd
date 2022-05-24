extends Node

var save_data = {}

var sound

var sound_default = {
	"fx_volume_scale":1.0,
	"music_volume_scale":1.0,
}

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
	"point_colors":[Color.red, Color.orange, Color.yellow, Color.green, Color.blue, Color.lightblue, Color.pink],

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
	"powerup_max_up_prob":1,
	"powerup_one_up_prob":0.2,
	"powerup_opalescence_prob":1,
	"powerup_oversheild_prob":3,
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
	"blocker_health":150,
}
var enemy = enemy_default.duplicate()

var player_default = {
	"speed":480.0,
	"player_speed_scale":1.0,
	"starting_health":3,
	"shrink_scalar":0.99,
	"min_scale":0.5,
	"gravity_radius":100.0,
	"gravity_pull_scale":1.0,
	"default_bullets_burst_wait_time":0.1,
	"is_active":true,
	"can_bomb":true,
	"starting_bombs":3,
	"powerup_point_value":1000,
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

var sound_settings_path = "user://settings.dat"
var save_path = "user://save.dat"

func _ready():
	var sound_settings_from_file = Global.load_var(sound_settings_path)
	if(sound_settings_from_file == null):
		sound = sound_default
	else:
		sound = sound_settings_from_file


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
