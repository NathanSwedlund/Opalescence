extends Node2D

export var max_size = 1.4
export var min_size = 0.05
export var grow_speed = 1.05
export var shrink_speed = 0.94
export var point_reward = -1000

var is_growing = true
var point_get_label_scene = load("res://Scenes/HelperScenes/UI/PointGetLabel.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var gpl = point_get_label_scene.instance()
	gpl.points_num = point_reward
	print(gpl.points_num)
	
	gpl.color = Color.white
	gpl.position = position
	get_parent().add_child(gpl)
	
	Global.player.add_points(point_reward)
	
	point_get_label_scene
	Global.player.play_enemey_explosion_sound()
	$WhiteBlast.emitting = true
	$BlackBlast.emitting = true

var target_time = 1.0/70.0
var current_time = 0.0
func _process(delta):
	current_time += delta
	if(current_time > target_time):
		current_time = 0.0
		$Light2D2.rotate(0.01)
		if(is_growing):
			if(scale.x >= max_size):
				is_growing = false
			else:
				scale *= grow_speed
		else:
			if(scale.x <= min_size):
				queue_free()
			else:
				scale *= shrink_speed
				modulate.a *= shrink_speed
				$Light2D.color.a *= shrink_speed
				$Light2D2.color.a *= shrink_speed
	
	#$LightTimer.start()
