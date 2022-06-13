extends Node2D

export var pos1x = 30
export var pos1y_mod = 50
export var pos1_max_num = 14
export var pos1_dir = Vector2(1,0)

var missile_scene = load("res://Scenes/HelperScenes/Enemies/Missile.tscn")

var count = 0
export var missile_num = 280
func _on_MissileTimer_timeout():
	var m = missile_scene.instance()
	add_to_group("Enemies")
	m.position.x = pos1x
	m.position.y = pos1y_mod * (count % pos1_max_num)
	m.direction = pos1_dir
	m.has_explosion = false
	add_child(m)
	
	count += 1
	if(count > missile_num):
		$WaitTimer.start()
		$MissileTimer.stop()


func die():
	for c in get_children():
		if(c != $WaitTimer and c != $MissileTimer):
			c.die()


func _on_WaitTimer_timeout():
	print("WAIT TIMER TIMEOTU")
	if(count == 0):
		$MissileTimer.start()
		$WaitTimer.stop()
	if(count > missile_num):
		print("BOSS COMPLETED")
		Global.level_timer.start_level_timer()
		queue_free()
