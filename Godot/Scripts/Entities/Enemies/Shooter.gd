extends KinematicBody2D

export var shoot_freq_range = [1.0, 2.0]

var missile_scene = load("res://Scenes/HelperScenes/Enemies/Missile.tscn")
var death_explosion_scene = load("res://Scenes/HelperScenes/Explosions/EnemyDeathExplosion.tscn")
var player:Node2D
export var health = 10
var base_health
onready var base_color = modulate
var point_reward = 550
var dist_ahead_to_spawn_missile = 70
var missiles_have_explosion = true
var can_shoot = true

var dist_squared_to_erase_points = 1000
func _ready():
	scale *= Settings.get_setting_if_exists(Settings.enemy, "shooter_gen_scale", 1.0)
	point_reward = Settings.get_setting_if_exists(Settings.enemy, "shooter_point_reward", point_reward)
	health = Settings.get_setting_if_exists(Settings.enemy, "shooter_health", health) * Settings.get_setting_if_exists(Settings.enemy, "enemy_health_scale", 1.0)
	shoot_freq_range = Settings.get_setting_if_exists(Settings.enemy, "shooter_shoot_freq_range", shoot_freq_range)
	base_health = health
	player = Global.player
	add_to_group("Enemies")
	add_to_group("Shooters")
	reset_shoot_timer()
	for point in get_tree().get_nodes_in_group("Points"):
		if(position.distance_squared_to(point.position) < dist_squared_to_erase_points):
			point.queue_free()
			
func reset_shoot_timer():
	var new_time = rand_range(shoot_freq_range[0], shoot_freq_range[1])
	$ShootTimer.wait_time = new_time	
	$ShootTimer.start()
	
func _process(delta):
	if(player != null):
		look_at(player.global_position)

func shoot():
	if(can_shoot == false):
		return 
		
	$ShootAudio.play()
	var missile = missile_scene.instance()
	var direction_to_player = global_position.direction_to(player.global_position).normalized()
	missile.rotation = (Vector2.ZERO).angle_to_point(direction_to_player)
	missile.direction = direction_to_player
	missile.parent_shooter = self
	missile.position = position
	missile.position += missile.direction*dist_ahead_to_spawn_missile
	missile.has_explosion = missiles_have_explosion
	get_parent().add_child(missile)

var damage_audio_base_pitch = 0.8
var damage_audio_max_pith = 2.0
func take_damage(damage, play_sound=true, color_override=null):
	$DamageAudio.play()
	$DamageTimer.start()
	health -= damage
	var color_target= Global.player.modulate if color_override == null else color_override
	
	var ratio = (base_health-health)/base_health
	modulate.r = ratio * color_target.r*0.6
	modulate.g = ratio * color_target.g*0.6
	modulate.b = ratio * color_target.b*0.6
	
	if(health <= 0):
		die()
	
	$DamageAudio.pitch_scale = lerp(damage_audio_base_pitch, damage_audio_max_pith, ratio)
	$DamageAudio.play()
	
func die():
	var explosion = death_explosion_scene.instance()
	explosion.position = position
	explosion.point_reward = point_reward
	get_parent().add_child(explosion)
	queue_free()

func _on_ShootTimer_timeout():
	shoot()
	reset_shoot_timer()

func _on_DamageTimer_timeout():
	modulate = base_color
