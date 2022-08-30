extends KinematicBody2D

export var base_speed = 300

var speed
var player:Node2D
export var base_health = 10
var health
var death_explosion_scene = load("res://Scenes/HelperScenes/Explosions/EnemyDeathExplosion.tscn")
export var point_reward = 400
export var use_global_settings = true

onready var base_color = modulate
var tags = {"enemy":true}
var starting_health
# Called when the node enters the scene tree for the first time.
func _ready():
	print("point_reward, ", point_reward)
	print("use_global_settings, ", use_global_settings)
	add_to_group("Enemies")
	add_to_group("Chasers")
	if(use_global_settings):
		scale *= Settings.get_setting_if_exists(Settings.enemy, "chaser_gen_scale", 1.0)
		point_reward = Settings.get_setting_if_exists(Settings.enemy, "chaser_point_reward", point_reward)
		base_health = Settings.get_setting_if_exists(Settings.enemy, "chaser_base_health", base_health) * Settings.get_setting_if_exists(Settings.enemy, "enemy_health_scale", 1.0)
	speed = base_speed * 1/(scale.y)
	health = scale.y * base_health
	starting_health = health
	print("point_reward, ", point_reward)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(player != null):
		look_at(player.global_position)
		var position_diff = (player.global_position - global_position)
		var position_diff_normalized = position_diff.normalized()

		var collision = move_and_collide( position_diff_normalized * speed*delta)
		if(collision != null):
			if(collision.collider.name == player.name):
				player.damage(self)
				die()

			elif(collision.collider.is_in_group("Enemies")):
				if(collision.collider.is_in_group("Chasers")):
					collision.collider.die()
					die()
				else:
					collision.collider.take_damage(10)
					die()
			elif(collision.collider.is_in_group("Points")):
				collision.collider.queue_free()
#			if(collision.collider.is_in_group("Explosion") )
#			elif(collision.collider.is_in_group("Lasers")):
#				take_damage(collision.collider.damage)
				#collision.collider.queue_free() # delete the point if it runs into it

var damage_audio_base_pitch = 1.0
var damage_audio_max_pith = 1.2
var has_died = false
func take_damage(damage, play_sound=true, color_override=null):
	health -= damage
	$DamageTimer.start()

	if(health <= 0):
		if(has_died == false):
			die()
		return

	var color_target= Global.player.modulate if color_override == null else color_override
	var ratio = (starting_health-health)/starting_health
	modulate.r = ratio * color_target.r*0.6
	modulate.g = ratio * color_target.g*0.6
	modulate.b = ratio * color_target.b*0.6

	$DamageAudio.pitch_scale = lerp(damage_audio_base_pitch, damage_audio_max_pith, ratio)
	$DamageAudio.play()

func die():
	has_died = true
	var explosion = death_explosion_scene.instance()
	explosion.position = position
	explosion.point_reward = point_reward
	explosion.scale_mod = scale.x
	get_parent().add_child(explosion)
	queue_free()

func _on_DamageTimer_timeout():
	modulate = base_color
