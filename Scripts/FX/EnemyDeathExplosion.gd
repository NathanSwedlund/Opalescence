extends Node2D

export var max_size = 1.4
export var min_size = 0.05
export var grow_speed = 1.05
export var shrink_speed = 0.94
export var point_reward = 0.0
export var scale_mod = 1.0

var explosion_pitch = 1.2
var explosion_vol_db = -15
var max_vol_db = -6

var is_growing = true
var point_get_label_scene = load("res://Scenes/HelperScenes/UI/PointGetLabel.tscn")
var shake_amp = 5
var shake_dur = 0.1
# Called when the node enters the scene tree for the first time.
func _ready():
	print("scale_mod, ", scale_mod)
	explosion_pitch -= scale_mod/5
	shake_dur *= scale_mod
	shake_amp *= scale_mod
	explosion_vol_db += (scale_mod-1)*5
	if(explosion_vol_db > max_vol_db):
		explosion_vol_db = max_vol_db
		
	print("explosion_vol_db, ", explosion_vol_db)
	
	Global.shakes["explosion"].start(shake_amp, shake_dur)
	if(Settings.shop["monocolor_color"] != null):
		modulate = Settings.shop["monocolor_color"]
		
	if(point_reward != 0):
		var gpl = point_get_label_scene.instance()
		gpl.points_num = point_reward
		gpl.color = Color.white
		gpl.position = position
		get_parent().add_child(gpl)

		Global.player.add_points(point_reward)

	Global.player.play_enemey_explosion_sound(explosion_pitch, explosion_vol_db)
	$WhiteBlast.emitting = true
	$BlackBlast.emitting = true
	
	$Light2D.color = modulate
	$Light2D2.color = modulate

var target_time = 1.0/70.0
var current_time = 0.0

var frames_per_update_options = {"Min":7, "Low":4, "Mid":3, "High":2, "Ultra":1}
var frames_per_update = frames_per_update_options[Settings.saved_settings["graphical_quality"]]
var current_frame = 0

var damage = 7

func _process(delta):
	current_time += delta
	if(current_time > target_time):
		current_frame += 1
		current_time = 0.0
		$Light2D2.rotate(0.01)
		if(current_frame % frames_per_update == 0):
			if(is_growing):
				if(scale.x >= max_size * scale_mod):
					is_growing = false
				else:
					scale *= pow(grow_speed, frames_per_update)
				for i in $Area2D.get_overlapping_bodies():
					if(i.is_in_group("Enemies")):
						i.take_damage(damage * delta * frames_per_update)
			else:
				if(scale.x <= min_size * scale_mod):
					queue_free()
				else:
					var shrink_speed_modded = pow(shrink_speed, frames_per_update)
					scale *= shrink_speed_modded
					modulate.a *= shrink_speed_modded
					$Light2D.color.a *= shrink_speed_modded
					$Light2D2.color.a *= shrink_speed_modded

	#$LightTimer.start()
