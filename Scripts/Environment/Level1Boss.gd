extends Node2D


export var boss_light_fade_speed = 1

var should_fade_light_in = true
var should_fade_light_out = false

var is_active = true

var missile_scene = load("res://Scenes/HelperScenes/Enemies/Missile.tscn")
export var pos1x = 30
export var pos1y_mod = 50
export var pos1_max_num = 14
export var pos1_dir = Vector2(1,0)

var count = 0
export var missile_num = 280

func _ready():
	$Light2D.color.a = 0
	should_fade_light_in = true
	
func _process(delta):
	if(should_fade_light_in):
		$Light2D.color.a = move_toward($Light2D.color.a, 1.0, boss_light_fade_speed*delta)
		if($Light2D.color.a == 1):
			should_fade_light_in = false
			
	if(should_fade_light_out):
		$Light2D.color.a = move_toward($Light2D.color.a, 0.0, boss_light_fade_speed*delta)
		

func _on_MissileTimer_timeout():
	if(is_active == false):
		return
		
	$MissileSpawnAudio.play()
	var m = missile_scene.instance()
	add_to_group("Enemies")
	add_to_group("Bosses")
	m.position.x = pos1x
	m.position.y = pos1y_mod * (count % pos1_max_num)
	m.direction = pos1_dir
	m.has_explosion = false
	add_child(m)
	
	count += 1
	if(count > missile_num):
		$WaitTimer.start()
		should_fade_light_out = true
		$MissileTimer.stop()

func die():
	for c in get_children():
		if((c in [$MissileTimer, $MissileSpawnAudio, $WaitTimer, $Light2D, $BossAlarm]) == false):
			c.die()

func _on_WaitTimer_timeout():
	print("WAIT TIMER TIMEOTU")
		
	if(count == 0):
		$MissileTimer.start()
		$WaitTimer.stop()
	if(count > missile_num):
		print("BOSS COMPLETED")
		boss_fight_completed()
		queue_free()
		
func boss_fight_completed():
	Global.level_timer.start_level_timer()
