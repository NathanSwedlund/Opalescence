extends Node2D

var chaser_scene  = load("res://Scenes/HelperScenes/Enemies/Chaser.tscn")
var shooter_scene = load("res://Scenes/HelperScenes/Enemies/Shooter.tscn")
var blocker_scene = load("res://Scenes/HelperScenes/Enemies/Blocker.tscn")
var comet_scene   = load("res://Scenes/HelperScenes/Enemies/Comet.tscn")

export var left_bound = 0
export var right_bound = 0
export var up_bound = 0
export var down_bound = 0
export var time_min = 0.8
export var time_max = 4.0
export var is_active = true
export var chaser_min_scale = 0.15
export var chaser_max_scale = 1.0
export var spawn_away_radius = 200

export var use_global_settings = true
var enemy_spawn_time_speed = 1.0

export var default_enemy_probabilities = {
	"chaser":  0.6,
	"shooter": 0.3,
	"comet":   0.0,
	"blocker": 0.1
}

var enemy_probabilities

onready var player = get_parent().find_node("Player")
# Called when the node enters the scene tree for the first time.
export var bound_buffer = 50
func _ready():
	enemy_probabilities = default_enemy_probabilities.duplicate()
	if(use_global_settings):
		left_bound = Settings.get_setting_if_exists(Settings.world, "left_bound", left_bound) + bound_buffer
		right_bound = Settings.get_setting_if_exists(Settings.world, "right_bound", right_bound) - bound_buffer
		up_bound = Settings.get_setting_if_exists(Settings.world, "up_bound", up_bound) + bound_buffer
		down_bound = Settings.get_setting_if_exists(Settings.world, "down_bound", down_bound) - bound_buffer

		chaser_min_scale = Settings.get_setting_if_exists(Settings.enemy, "chaser_min_scale", chaser_min_scale)
		chaser_max_scale = Settings.get_setting_if_exists(Settings.enemy, "chaser_max_scale", chaser_max_scale)

		time_min = Settings.get_setting_if_exists(Settings.factory, "enemy_time_min", time_min)
		time_max = Settings.get_setting_if_exists(Settings.factory, "enemy_time_max", time_max)
		enemy_spawn_time_speed = Settings.get_setting_if_exists(Settings.factory, "enemy_spawn_time_speed", enemy_spawn_time_speed)
		
		enemy_probabilities["blocker"] = Settings.get_setting_if_exists(Settings.factory, "enemy_blocker_prob", enemy_probabilities["blocker"]) * Settings.get_setting_if_exists(Settings.factory, "blocker_spawn_scale", 1.0)
		enemy_probabilities["chaser"]  = Settings.get_setting_if_exists(Settings.factory, "enemy_chaser_prob", enemy_probabilities["chaser"])
		enemy_probabilities["comet"]   = Settings.get_setting_if_exists(Settings.factory, "enemy_comet_prob", enemy_probabilities["comet"])
		enemy_probabilities["shooter"] = Settings.get_setting_if_exists(Settings.factory, "enemy_shooter_prob", enemy_probabilities["shooter"])
		
	randomize()


func pick_enemy():
	# Between 0 and 1
	var rand_num = randf()

	for key in enemy_probabilities.keys():
		rand_num -= enemy_probabilities[key]
		if(rand_num <= 0):
			return key

func spawn_enemy():
	var enemy_type = pick_enemy()
	if(enemy_type == "chaser"):
		spawn_chaser()
	elif(enemy_type == "shooter"):
		spawn_shooter()
	elif(enemy_type == "blocker"):
		spawn_blocker()
	elif(enemy_type == "comet"):
		spawn_chaser()

func reset():
	is_active = Settings.get_setting_if_exists(Settings.factory, "enemy_is_active", is_active)
	_ready()

func distance_to_closest_entity(point):
	var closest_dist = INF

	if(point.distance_to(player.position) < closest_dist):
		closest_dist = point.distance_to(player.position)

	for i in $Enemies.get_children():
		if(point.distance_to(i.position) < closest_dist):
			closest_dist = point.distance_to(i.position)

	return closest_dist

func make_spawn_location():
	var position_x = rand_range(left_bound, right_bound)
	var position_y = rand_range(up_bound, down_bound)
	var random_location = Vector2(position_x, position_y)

	var spawn_attempt_max = 10
	var spawn_attempt_count = 0

	while(distance_to_closest_entity(random_location) < spawn_away_radius):
		position_x = rand_range(left_bound, right_bound)
		position_y = rand_range(up_bound, down_bound)
		random_location = Vector2(position_x, position_y)
		spawn_attempt_count += 1
		if(spawn_attempt_count >= spawn_attempt_max):
			return

	return random_location


func spawn_chaser():
	var spawn_position = make_spawn_location()
	if(spawn_position == null):
		return

	var enemy = chaser_scene.instance()
	enemy.position = spawn_position
	enemy.scale *= rand_range(chaser_min_scale, chaser_max_scale)
	enemy.player = player
	$Enemies.add_child(enemy)

func spawn_shooter():
	var spawn_position = make_spawn_location()
	if(spawn_position == null):
		return

	var enemy = shooter_scene.instance()
	enemy.position = spawn_position
	enemy.player = player
	$Enemies.add_child(enemy)

func spawn_comet():
	pass

func spawn_blocker():
	var spawn_position = make_spawn_location()
	if(spawn_position == null):
		return

	var enemy = blocker_scene.instance()
	enemy.position = spawn_position
	$Enemies.add_child(enemy)

func kill_all():
	for c in $Enemies.get_children():
		if(c.is_in_group("Enemies")):
			c.point_reward = 0
			c.die()

func _on_Timer_timeout():
	if(is_active):
		spawn_enemy()

	var time_until_next = rand_range(time_min, time_max) / enemy_spawn_time_speed
	$Timer.wait_time = time_until_next 
