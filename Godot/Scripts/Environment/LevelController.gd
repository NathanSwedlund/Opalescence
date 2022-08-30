extends Node2D

export var default_level_time = 60
export var universal_level_settings_scales = {
	"points_scale":1.2,
	"enemy_time_min":0.9,
	"enemy_time_max":0.9,
	"light_scale":0.9,
	"light_fade_scale":0.96,
	"cahser_min_scale":0.9,
	"chaser_max_scale":0.9,
	"enemy_health_scale":1.1,
}

export var level_title = "Level 0"
export var level_count = 0
export var starting_level = 0
export var level_time_lengths = [60, 60, 60, 60, 60, 60, 60, 60, 60, 60]
export var level_settings_scales = [{},{},{},{},{},{},{},{},{},{}] # multiplies settings by values
export var level_settings_mods = [{},{},{},{},{},{},{},{},{},{}] # adds values to settings
export var level_settings_setters = [{},{},{},{},{},{},{},{},{},{}]
var currrent_level = 0
var bosses = [null,null,null,null,null,null,null,null,null,null,null,]

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.level_timer = self
	if(Settings.world["is_mission"]):
		queue_free()

	bosses[2] = load("res://Scenes/HelperScenes/Enemies/Boss1.tscn")
	bosses[4] = load("res://Scenes/HelperScenes/Boss2Container.tscn")
	bosses[6] = load("res://Scenes/HelperScenes/Boss3Container.tscn")


	currrent_level = starting_level
	$CountdownTimer.wait_time = level_time_lengths[currrent_level]
	$CountdownTimer.start()

func increase_level():
	currrent_level += 1

	if(level_has_boss(currrent_level)):
		var boss = bosses[currrent_level].instance()
		get_parent().find_node("EnemyFactory").find_node("Enemies").add_child(boss)
		level_title = "Level " + str(currrent_level) + " Boss"
		$CountdownTimer.stop()

	else:
		start_level_timer()

		for dict in [Settings.player, Settings.world, Settings.factory, Settings.enemy]:
			if(currrent_level < level_count): # Level specific setting changes
				for key in level_settings_scales[currrent_level-1].keys():
					if(dict.has(key)):
						dict[key] *= level_settings_scales[currrent_level-1][key]

				for key in level_settings_mods[currrent_level-1].keys():
					if(dict.has(key)):
						dict[key] += level_settings_mods[currrent_level-1][key]

				for key in level_settings_setters[currrent_level-1].keys():
					if(dict.has(key)):
						dict[key] = level_settings_setters[currrent_level-1][key]

			# Universal setting changers for every level
			for key in universal_level_settings_scales.keys():
				if(dict.has(key)):
					dict[key] *= universal_level_settings_scales[key]

		# Resetting levels
		Global.player.reset_settings()
		get_parent().find_node("PointFactory").reset()
		get_parent().find_node("EnemyFactory").reset()
		get_parent().find_node("PowerupFactory").reset()



func level_has_boss(level):
	if(level > level_count):
		return false
	if(bosses[level] == null):
		return false

	return true

func start_level_timer():
	level_title = "Level " + str(currrent_level)
	$CountdownTimer.stop()
	if(currrent_level < level_count):
		$CountdownTimer.wait_time = level_time_lengths[currrent_level]
	else:
		$CountdownTimer.wait_time = default_level_time
	$CountdownTimer.start()


func _on_CountdownTimer_timeout():
	increase_level()

func stop():
	$CountdownTimer.stop()
#	for c in get_children():
#		if(c != $CountdownTimer and c != $LevelLabel):
#			c.queue_free()
#
#func _process(delta):
##	if(Global.player):
##		$LevelLabel2.modulate = Global.player.modulate
##		print($LevelLabel2.modulate)
#	if(Input.is_action_just_pressed("ui_q")):
#		increase_level()
