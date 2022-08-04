extends Node2D

export var max_size = 1.4
export var min_size = 0.05
export var grow_speed = 1.05
export var shrink_speed = 0.94
export var point_reward = 0.0
export var scale_mod = 1.0

var shrink_speed_optimized
var explosion_pitch = 1.2
var explosion_vol_db_mod = null
var max_pitch = 2.0
var min_pitch = 0.4
var max_vol_db = 6
var min_vol_db = -10

var is_growing = true
var point_get_label_scene = load("res://Scenes/HelperScenes/UI/PointGetLabel.tscn")
var shake_amp = 12
var shake_dur = 0.3
var damage = 7

# Called when the node enters the scene tree for the first time.
func _ready():
	var explosion_count = len(get_tree().get_nodes_in_group("Explosions"))
	
	if(explosion_vol_db_mod == null):
		explosion_vol_db_mod = (scale_mod-1)*5
		explosion_pitch -= scale_mod/5
		shake_dur *= scale_mod
		shake_amp *= scale_mod
		if(explosion_vol_db_mod > max_vol_db):
			explosion_vol_db_mod = max_vol_db
		if(explosion_vol_db_mod < min_vol_db):
			explosion_vol_db_mod = min_vol_db
	
	Global.shakes["explosion"].start(shake_amp, shake_dur, 30)
	if(Settings.shop["monocolor_color"] != null):
		modulate = Settings.shop["monocolor_color"]
		
	if(point_reward != 0):
		var gpl = point_get_label_scene.instance()
		gpl.points_num = point_reward
		gpl.color = Color.white
		gpl.position = position
		get_parent().add_child(gpl)

		Global.player.add_points(point_reward)


	$WhiteBlast.emitting = true
	$BlackBlast.emitting = true
	
	$Light2D.color = modulate
	
	
	# Initial damage
	for e in get_tree().get_nodes_in_group("Enemies"):
		if(global_position.distance_squared_to(e.global_position) < 60000*scale.x and e.is_in_group("Missiles") == false and e.is_in_group("Explosions") == false):
			e.take_damage(damage/1.5, true, Color.white)
			
	if($EnemyExplosionSound != null):
		if(Global.seconds_since_last_enemy_explosion_sound < 0.035):
			$EnemyExplosionSound.volume_db -= 10*explosion_count
		else:
			print("\n$EnemyExplosionSound.volume_db1, ", $EnemyExplosionSound.volume_db)
			$EnemyExplosionSound.volume_db -= 1*explosion_count
			print("$EnemyExplosionSound.volume_db, ", $EnemyExplosionSound.volume_db)
			$EnemyExplosionSound.pitch_scale = min( max(explosion_pitch, min_pitch), max_pitch)
			if(explosion_vol_db_mod != null):
				$EnemyExplosionSound.volume_db += explosion_vol_db_mod

		$EnemyExplosionSound.play()

	Global.seconds_since_last_enemy_explosion_sound = 0.0
	

var target_time = 1.0/70.0
var current_time = 0.0

var frames_per_update_options = {"Min":20, "Low":4, "Mid":3, "High":2, "Ultra":1}
var frames_per_update = frames_per_update_options[Settings.saved_settings["graphical_quality"]]
var current_frame = 0


func _process(delta):
	current_time += delta
	if(current_time > target_time):
		current_frame += 1
		current_time = 0.0
		
		if(current_frame % frames_per_update == 0):
			# optimization for explosions
			shrink_speed_optimized = shrink_speed
			var fps = Engine.get_frames_per_second()
			if (fps < 10):
				queue_free()
			elif (fps < 20):
				shrink_speed_optimized /= 1.5
				grow_speed *= 1.5
			elif (fps < 30):
				shrink_speed_optimized /= 1.2
				grow_speed *= 1.2
			elif (fps < 40):
				shrink_speed_optimized /= 1.05
				grow_speed *= 1.05
			elif (fps < 50):
				shrink_speed_optimized /= 1.02
				grow_speed *= 1.02
			# explosion changing calcs
			if(is_growing):
				if(scale.x >= max_size * scale_mod):
					is_growing = false
				else:
					scale *= pow(grow_speed, frames_per_update)
#				for i in $Area2D.():
#					if(i.is_in_group("Enemies")):
#						i.take_damage(damage * delta * frames_per_update, true, Color.white)
				for e in get_tree().get_nodes_in_group("Enemies"):
					if(global_position.distance_squared_to(e.global_position) < 60000*scale.x and e.is_in_group("Missiles") == false):
						e.take_damage(damage * delta * frames_per_update, true, Color.white)
			else:
				if(scale.x <= min_size * scale_mod):
					queue_free()
				else:
					var shrink_speed_modded = pow(shrink_speed_optimized, frames_per_update)
					scale *= shrink_speed_modded
					modulate.a *= shrink_speed_modded
					$Light2D.color.a *= shrink_speed_modded

	#$LightTimer.start()
