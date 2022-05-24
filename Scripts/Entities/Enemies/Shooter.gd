extends KinematicBody2D

export var shoot_freq_range = [1.0, 2.0]

var missile_scene = load("res://Scenes/HelperScenes/Enemies/Missile.tscn")
var death_explosion_scene = load("res://Scenes/HelperScenes/Explosions/EnemyDeathExplosion.tscn")
var player:Node2D
export var health = 10
onready var base_color = modulate
var point_reward = 550

func _ready():
	scale *= Settings.get_setting_if_exists(Settings.enemy, "shooter_gen_scale", 1.0)
	point_reward = Settings.get_setting_if_exists(Settings.enemy, "shooter_point_reward", point_reward)
	health = Settings.get_setting_if_exists(Settings.enemy, "shooter_health", health) * Settings.get_setting_if_exists(Settings.enemy, "enemy_health_scale", 1.0)
	shoot_freq_range = Settings.get_setting_if_exists(Settings.enemy, "shooter_shoot_freq_range", shoot_freq_range)
	
	add_to_group("Enemies")
	add_to_group("Shooters")
	reset_shoot_timer()

func reset_shoot_timer():
	var new_time = rand_range(shoot_freq_range[0], shoot_freq_range[1])
	$ShootTimer.wait_time = new_time	
	$ShootTimer.start()
	
func _process(delta):
	if(player != null):
		look_at(player.position)

func shoot():
	$ShootAudio.play()
	var missile = missile_scene.instance()
	var direction_to_player = position.direction_to(player.position).normalized()
	missile.rotation = (Vector2.ZERO).angle_to_point(direction_to_player)
	missile.direction = direction_to_player
	missile.parent_shooter = self
	missile.position = position
	get_parent().add_child(missile)

func take_damage(damage):
	$DamageAudio.play()
	modulate = Color.white
	$DamageTimer.start()
	health -= damage
	if(health <= 0):
		die()

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
