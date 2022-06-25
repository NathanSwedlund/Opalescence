extends KinematicBody2D

export var speed = 1
export var health = 150
var death_explosion_scene = load("res://Scenes/HelperScenes/Explosions/EnemyDeathExplosion.tscn")

var point_reward = 3000

var point_to_cover = null
var looking_for_point = true

onready var base_color = modulate
var base_health
func _ready():
	scale *= Settings.get_setting_if_exists(Settings.enemy, "blocker_gen_scale", 1.0)
	speed *= global_scale.x
	point_reward = Settings.get_setting_if_exists(Settings.enemy, "blocker_point_reward", point_reward)
	health = Settings.get_setting_if_exists(Settings.enemy, "blocker_health", health) * Settings.get_setting_if_exists(Settings.enemy, "enemy_health_scale", 1.0)
	base_health = health
	
	add_to_group("Enemies")
	add_to_group("Blockers")

var collision_damage = 30
var blocker_damage_mod = 1.0
func _physics_process(delta):
	if(point_to_cover != null and is_instance_valid(point_to_cover)):
		var move_direction = position.direction_to(point_to_cover.position)
		var collision = move_and_collide(move_direction*speed, delta)
		if(collision != null):
			if(collision.collider.name == "Player"):
				collision.collider.damage()
			elif(collision.collider.is_in_group("Blockers")):
				take_damage(blocker_damage_mod * collision_damage * delta)
			elif(collision.collider.is_in_group("Enemies")):
				collision.collider.die()
				take_damage(collision_damage)
			elif(collision.collider.is_in_group("Points")):
				collision.collider.queue_free()


	elif(is_instance_valid(point_to_cover) == false):
		point_to_cover = null
		looking_for_point = true


func _on_PointCheckTimer_timeout():
	if(looking_for_point):
		looking_for_point = false
		var closest_dist = INF
		var closest_point = null
		for i in get_tree().get_nodes_in_group("Points"):
			var dist_to_i = position.distance_squared_to(i.position)
			if(dist_to_i < closest_dist):
				closest_dist = dist_to_i
				closest_point = i

		point_to_cover = closest_point

	else:
		if(point_to_cover == null):
			looking_for_point = true

var damage_audio_base_pitch = 0.2
var damage_audio_max_pith = 3.5
func take_damage(damage, play_sound=true):
	$DamageTimer.start()
	health -= damage
	var ratio = (base_health-health)/base_health
	modulate.r = ratio * Global.player.modulate.r*0.6
	modulate.g = ratio * Global.player.modulate.g*0.6
	modulate.b = ratio * Global.player.modulate.b*0.6
	if(health <= 0):
		die()

	if(play_sound):
		$DamageAudio.pitch_scale = lerp(damage_audio_base_pitch, damage_audio_max_pith, ratio)
		$DamageAudio.play()

func die():
	var explosion = death_explosion_scene.instance()
	explosion.position = position
	explosion.point_reward = point_reward
	explosion.scale_mod = scale.x*1.5
	get_parent().add_child(explosion)
	queue_free()

func _on_DamageTimer_timeout():
	modulate = base_color
