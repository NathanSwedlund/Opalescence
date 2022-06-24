extends Node2D

export var boss_light_fade_speed = 1

var should_fade_light_in = false
var should_fade_light_out = false

var is_active = true
var count = 0
export var missile_num = 280
var boss_scene
var boss3 = null

func _ready():
	add_to_group("Bosses")
	add_to_group("Enemies")
	boss_scene = load("res://Scenes/HelperScenes/Enemies/Boss3.tscn")
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
	should_fade_light_in = true
	should_fade_light_out = false

func die():
	if(boss3 != null):
		boss3.pause_shooting(1.4)

	for m in get_tree().get_nodes_in_group("Missiles"):
		m.has_explosion = false
		m.die()

var starting = true
func _on_WaitTimer_timeout():
	if(starting):
		boss3 = boss_scene.instance()
		boss3.add_to_group("Boss3")
		add_child(boss3)
		starting = false
		fade_light_out()
	else:
		Global.world.find_node("EnemyFactory").is_active = true
		boss_fight_completed()

func boss_fight_completed():
	Global.level_timer.start_level_timer()
	queue_free()
