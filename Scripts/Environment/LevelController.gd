extends Node2D

export var level_time = 60
export var level_settings_scales = [{}, {}, {}] # multiplies settings by values
export var level_settings_mods = [{},{},{}] # adds values to settings
export var level_settings_setters = [{},{},{}]
export var level_count = 0
var currrent_level = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if(Settings.world["is_mission"]):
		return
		$LevelLabel.visible = false
	
	$LevelLabel.fade_out()
	$CountdownTimer.wait_time = level_time
	$CountdownTimer.start()

func increase_level():
	if(currrent_level >= level_count):
		print("Already at Max level")
		print(currrent_level, ", ", level_count)
		return
		
	currrent_level += 1
	$LevelLabel.text = "Level " + str(currrent_level)
	$LevelLabel.fade_out()
	
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
	
	print("Now at Level ", str(currrent_level))
#	print(Settings.player)
#	print(Settings.world)
#	print(Settings.enemy)
	print(Settings.factory)
	print("\n\n")

func _on_CountdownTimer_timeout():
	print("LEVEL TIMER GO")
	increase_level()
