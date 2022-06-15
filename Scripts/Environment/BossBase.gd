extends Node2D

export var boss_light_fade_speed = 1

var should_fade_light_in = false
var should_fade_light_out = false

var is_active = true
var count = 0
export var missile_num = 280

func _ready():
	add_to_group("Bosses")
	fade_light_in()
	
func _process(delta):
	if(should_fade_light_in):
		$Light2D.color.a = move_toward($Light2D.color.a, 1.0, boss_light_fade_speed*delta)
		if($Light2D.color.a == 1):
			should_fade_light_in = false
			
	if(should_fade_light_out):
		$Light2D.color.a = move_toward($Light2D.color.a, 0.0, boss_light_fade_speed*delta)
		
func fade_light_out():
	should_fade_light_in = false
	should_fade_light_out = true
	
func fade_light_in():
	$Light2D.color.a = 0
	should_fade_light_in = false
	should_fade_light_out = true
	
func die():
	pass

func _on_WaitTimer_timeout():
	pass
	
func boss_fight_completed():
	print("BOSS COMPLETED")
	Global.level_timer.start_level_timer()
	queue_free()
