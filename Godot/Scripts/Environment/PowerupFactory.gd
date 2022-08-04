extends Node2D

export var is_active = true
export var use_global_settings = true

export var left_bound = 0
export var right_bound = 0
export var up_bound = 0
export var down_bound = 0
export var time_min = 20.0
export var time_max = 60.0

export var powerup_probabilities = {
	"barrage":1/20.0,
	"bombastic":1.0/20.0,
	"bullet_time":1.0/20.0,
	"gravity_well":1.0/20.0,
	"incendiary":1.0/20.0,
	"max_bomb":1.0/20.0,
	"one_up":4.0/20.0,
	"opalescence":0.5/20.0,
	"overshield":2.5/20.0,
	"unmaker":1.0/20.0,
	"vision":1.0/20.0
}

export var key_to_name = {
	"barrage":"Barrage",
	"bombastic":"Bombastic",
	"bullet_time":"BulletTime",
	"gravity_well":"GravityWell",
	"incendiary":"Incendiary",
	"max_bomb":"MaxBomb",
	"one_up":"OneUp",
	"opalescence":"Opalescence",
	"overshield":"OverShield",
	"unmaker":"Unmaker",
	"vision":"Vision"
}

var readable_names = {
	"Barrage":"Barrage",
	"Bombastic":"Bombastic",
	"BulletTime":"Bullet Time",
	"GravityWell":"Gravity Well",
	"Incendiary":"Incendiary",
	"MaxBomb":"Max Bomb",
	"OneUp":"One Up",
	"Opalescence":"Opalescence",
	"OverShield":"Overshield",
	"Unmaker":"Unmaker",
	"Vision":"Vision"
}
var powerup_scenes = {
	"barrage":load("res://Scenes/HelperScenes/Powerups/Barrage.tscn"),
	"bombastic":load("res://Scenes/HelperScenes/Powerups/Bombastic.tscn"),
	"bullet_time":load("res://Scenes/HelperScenes/Powerups/BulletTime.tscn"),
	"gravity_well":load("res://Scenes/HelperScenes/Powerups/GravityWell.tscn"),
	"incendiary":load("res://Scenes/HelperScenes/Powerups/Incendiary.tscn"),
	"max_bomb":load("res://Scenes/HelperScenes/Powerups/MaxBomb.tscn"),
	"one_up":load("res://Scenes/HelperScenes/Powerups/OneUp.tscn"),
	"opalescence":load("res://Scenes/HelperScenes/Powerups/Opalescence.tscn"),
	"overshield":load("res://Scenes/HelperScenes/Powerups/OverShield.tscn"),
	"unmaker":load("res://Scenes/HelperScenes/Powerups/Unmaker.tscn"),
	"vision":load("res://Scenes/HelperScenes/Powerups/Vision.tscn")
}

onready var player = get_parent().find_node("Player")
var powerup_spawn_time_speed = 1.0	

# Called when the node enters the scene tree for the first time.
func _ready():
	if(use_global_settings):
		left_bound = Settings.get_setting_if_exists(Settings.world, "left_bound", left_bound)
		right_bound = Settings.get_setting_if_exists(Settings.world, "right_bound", right_bound)
		up_bound = Settings.get_setting_if_exists(Settings.world, "up_bound", up_bound)
		down_bound = Settings.get_setting_if_exists(Settings.world, "down_bound", down_bound)

		time_min = Settings.get_setting_if_exists(Settings.factory, "powerup_time_min", time_min)
		time_max = Settings.get_setting_if_exists(Settings.factory, "powerup_time_max", time_max)
		powerup_spawn_time_speed = Settings.get_setting_if_exists(Settings.factory, "powerup_spawn_time_speed", powerup_spawn_time_speed)
		
		powerup_probabilities["barrage"]      = Settings.get_setting_if_exists(Settings.factory, "powerup_barrage_prob", powerup_probabilities["barrage"])
		powerup_probabilities["bombastic"]    = Settings.get_setting_if_exists(Settings.factory, "powerup_bombastic_prob", powerup_probabilities["bombastic"])
		powerup_probabilities["bullet_time"]  = Settings.get_setting_if_exists(Settings.factory, "powerup_bullet_time_prob", powerup_probabilities["bullet_time"])
		powerup_probabilities["gravity_well"] = Settings.get_setting_if_exists(Settings.factory, "powerup_gravity_well_prob", powerup_probabilities["gravity_well"])
		powerup_probabilities["incendiary"]   = Settings.get_setting_if_exists(Settings.factory, "powerup_incendiary_prob", powerup_probabilities["incendiary"])
		powerup_probabilities["max_bomb"]     = Settings.get_setting_if_exists(Settings.factory, "powerup_max_bomb_prob", powerup_probabilities["max_bomb"])
		powerup_probabilities["one_up"]       = Settings.get_setting_if_exists(Settings.factory, "powerup_one_up_prob", powerup_probabilities["one_up"])
		powerup_probabilities["opalescence"]  = Settings.get_setting_if_exists(Settings.factory, "powerup_opalescence_prob", powerup_probabilities["opalescence"])
		powerup_probabilities["overshield"]   = Settings.get_setting_if_exists(Settings.factory, "powerup_overshield_prob", powerup_probabilities["overshield"])
		powerup_probabilities["unmaker"]      = Settings.get_setting_if_exists(Settings.factory, "powerup_unmaker_prob", powerup_probabilities["unmaker"])
		powerup_probabilities["vision"]       = Settings.get_setting_if_exists(Settings.factory, "powerup_vision_prob", powerup_probabilities["vision"])

		if(Settings.get_setting_if_exists(Settings.player, "can_bomb", true) == false):
			powerup_probabilities["bombastic"] = 0.0
			powerup_probabilities["max_bomb"] = 0.0
		if(Settings.get_setting_if_exists(Settings.player, "can_shoot", true) == false):
			powerup_probabilities["incendiary"] = 0.0
			powerup_probabilities["barrage"] = 0.0
		if(Settings.get_setting_if_exists(Settings.player, "can_laser", true) == false):
			powerup_probabilities["unmaker"] = 0.0

	reset_spawn_timer()

func reset():
	if(use_global_settings):
		is_active = Settings.get_setting_if_exists(Settings.factory, "powerup_is_active", is_active)
	reset_spawn_timer()
	_ready()

func kill_all():
	for c in get_children():
		if(c.name != "SpawnTimer"):
			c.queue_free()

func spawn_powerup():
	#print("trying spawn powerup")
	if(!is_active):
		return
	#print("powerup Factory not active")
	
	var mult = 0.0 # multiple of probabilities
	for key in powerup_probabilities:
		mult += powerup_probabilities[key]

	var r = randf() * mult

	for key in powerup_probabilities:
		r -= powerup_probabilities[key]
		if(key == "bomb_up"):
			continue
		
		if(r <= 0 and get_node(key_to_name[key]) == null): # spawn the current powerup
			var powerup = powerup_scenes[key].instance()
			var position_x = rand_range(left_bound, right_bound)
			var position_y = rand_range(up_bound, down_bound)

			powerup.position = Vector2(position_x, position_y)
			powerup.get_node("PowerupPill").player = player
			add_child(powerup)
			break


func reset_spawn_timer():
	$SpawnTimer.wait_time = rand_range(time_min, time_max) / powerup_spawn_time_speed
	$SpawnTimer.start()

func _on_SpawnTimer_timeout():
	spawn_powerup()
	reset_spawn_timer()
