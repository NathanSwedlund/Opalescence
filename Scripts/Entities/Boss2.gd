extends Node2D

export var boss_light_fade_speed = 1

var should_fade_light_in = false
var should_fade_light_out = false

var is_active = true
var starting = true
var finishing = false

var count = 0
export var missile_num = 280
var chaser_scene = load("res://Scenes/HelperScenes/Enemies/Boss2.tscn")

func _ready():
	Global.world.find_node("EnemyFactory").kill_all()
	
	starting = true
	add_to_group("Bosses")
	fade_light_in()
	
func _process(delta):
	if(starting):
		Global.world.find_node("EnemyFactory").is_active = false
	if(should_fade_light_in):
		$Light2D.color.a = move_toward($Light2D.color.a, 1.0, boss_light_fade_speed*delta)
		if($Light2D.color.a == 1):
			should_fade_light_in = false
			fade_light_out()
			
	if(should_fade_light_out):
		$Light2D.color.a = move_toward($Light2D.color.a, 0.0, boss_light_fade_speed*delta)
		
	if(finishing == false and starting == false and len(get_tree().get_nodes_in_group("Boss2")) == 0):
		finishing = true
		$WaitTimer.start()
		
func fade_light_out():
	should_fade_light_in = false
	should_fade_light_out = true
	
func fade_light_in():
	$Light2D.color.a = 0
	should_fade_light_in = true
	should_fade_light_out = false
	
func die():
	pass

func _on_WaitTimer_timeout():
	if(starting):
		var c = chaser_scene.instance()
		c.add_to_group("Boss2")
		c.position = $Light2D.position
		c.player = Global.player
		c.use_global_settings = false
		c.base_health = 400
		c.base_speed *= 10
		c.point_reward = 5000
		add_child(c)
		starting = false
	else:
		Global.world.find_node("EnemyFactory").is_active = true
		boss_fight_completed()
	
func boss_fight_completed():
	print("BOSS COMPLETED")
	Global.level_timer.start_level_timer()
	queue_free()
