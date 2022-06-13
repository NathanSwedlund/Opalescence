extends Node2D

export var level_time_lengths = [60, 60, 60, 60, 60, 60, 60, 60, 60, 60]

export var level_settings_scales = [
	{	
		"points_scale":1.2,
		"enemy_time_min":0.9,
		"enemy_time_max":0.9,
		"light_scale":0.9,
		"light_fade_scale":0.96,
		"cahser_min_scale":0.9,
		"chaser_max_scale":0.9,
		"enemy_health_scale":1.1,
	},
	{
		"points_scale":1.2,
		"enemy_time_min":0.9,
		"enemy_time_max":0.9,
		"light_scale":0.9,
		"light_fade_scale":0.96,
		"cahser_min_scale":0.9,
		"chaser_max_scale":0.9,
		"enemy_health_scale":1.1,
	},
	{
		"points_scale":1.2,
		"enemy_time_min":0.9,
		"enemy_time_max":0.9,
		"light_scale":0.9,
		"light_fade_scale":0.96,
		"cahser_min_scale":0.9,
		"chaser_max_scale":0.9,
		"enemy_health_scale":1.1,
	},
	{
		"points_scale":1.2,
		"enemy_time_min":0.9,
		"enemy_time_max":0.9,
		"light_scale":0.9,
		"light_fade_scale":0.96,
		"cahser_min_scale":0.9,
		"chaser_max_scale":0.9,
		"enemy_health_scale":1.1,
	},
	{
		"points_scale":1.2,
		"enemy_time_min":0.9,
		"enemy_time_max":0.9,
		"light_scale":0.9,
		"light_fade_scale":0.96,
		"cahser_min_scale":0.9,
		"chaser_max_scale":0.9,
		"enemy_health_scale":1.1,
	},
	{
		"points_scale":1.2,
		"enemy_time_min":0.9,
		"enemy_time_max":0.9,
		"light_scale":0.9,
		"light_fade_scale":0.96,
		"cahser_min_scale":0.9,
		"chaser_max_scale":0.9,
		"enemy_health_scale":1.1,
	},
	{
		"points_scale":1.2,
		"enemy_time_min":0.9,
		"enemy_time_max":0.9,
		"light_scale":0.9,
		"light_fade_scale":0.96,
		"cahser_min_scale":0.9,
		"chaser_max_scale":0.9,
		"enemy_health_scale":1.1,
	},
	{
		"points_scale":1.2,
		"enemy_time_min":0.9,
		"enemy_time_max":0.9,
		"light_scale":0.9,
		"light_fade_scale":0.96,
		"cahser_min_scale":0.9,
		"chaser_max_scale":0.9,
		"enemy_health_scale":1.1,
	},
	{
		"points_scale":1.2,
		"enemy_time_min":0.9,
		"enemy_time_max":0.9,
		"light_scale":0.9,
		"light_fade_scale":0.96,
		"cahser_min_scale":0.9,
		"chaser_max_scale":0.9,
		"enemy_health_scale":1.1,
	},
	{
		"points_scale":1.2,
		"enemy_time_min":0.9,
		"enemy_time_max":0.9,
		"light_scale":0.9,
		"light_fade_scale":0.96,
		"cahser_min_scale":0.9,
		"chaser_max_scale":0.9,
		"enemy_health_scale":1.1,
	},
] # multiplies settings by values

export var level_settings_mods = [{},{},{},{},{},{},{},{},{},{}] # adds values to settings
export var level_settings_setters = [{},{},{},{},{},{},{},{},{},{}]
export var level_count = 0
export var starting_level = 0
var currrent_level = 0

var bosses = [null,null,null,null,null,null,null,null,null,null,null,]

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.level_timer = self
	if(Settings.world["is_mission"]):
		queue_free()
		
	bosses[1] = load("res://Scenes/HelperScenes/Level1Boss.tscn")
			
	
	currrent_level = starting_level
	$LevelLabel.fade_out()
	$CountdownTimer.wait_time = level_time_lengths[currrent_level]
	$CountdownTimer.start()

func increase_level():
	if(currrent_level >= level_count):
		print("Already at Max level")
		print(currrent_level, ", ", level_count)
		return
		
	currrent_level += 1
	if(bosses[currrent_level] != null):
		var boss = bosses[currrent_level].instance()
		get_parent().find_node("EnemyFactory").find_node("Enemies").add_child(boss)
		$LevelLabel.text = "Level " + str(currrent_level) + " Boss"
		$LevelLabel.fade_out()
		$CountdownTimer.stop()
		
	else:
		start_level_timer()
		
		for dict in [Settings.player, Settings.world, Settings.factory, Settings.enemy]:
			for key in level_settings_scales[currrent_level-1].keys():
				if(dict.has(key)):
					print("updating KEY, ", key, "    ", dict)
					dict[key] *= level_settings_scales[currrent_level-1][key]
					
			for key in level_settings_mods[currrent_level-1].keys():
				if(dict.has(key)):
					dict[key] += level_settings_mods[currrent_level-1][key]
			
			for key in level_settings_setters[currrent_level-1].keys():
				if(dict.has(key)):
					dict[key] = level_settings_setters[currrent_level-1][key]
		
		Global.player.reset_settings()
		get_parent().find_node("PointFactory").reset()
		get_parent().find_node("EnemyFactory").reset()
		get_parent().find_node("PowerupFactory").reset()
		
#		print("Now at Level ", str(currrent_level))
#		print(Settings.factory)
#		print("\n\n")

func start_level_timer():
	$LevelLabel.text = "Level " + str(currrent_level)
	$LevelLabel.fade_out()
	$CountdownTimer.stop()
	$CountdownTimer.wait_time = level_time_lengths[currrent_level]
	$CountdownTimer.start()
	

func _on_CountdownTimer_timeout():
	print("LEVEL TIMER GO")
	increase_level()

func stop():
	$CountdownTimer.stop()
#	for c in get_children():
#		if(c != $CountdownTimer and c != $LevelLabel):
#			c.queue_free()
