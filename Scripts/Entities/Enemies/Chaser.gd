extends KinematicBody2D

export var base_speed = 300

var speed
var player:Node2D
export var base_health = 10
var health
var death_explosion_scene = load("res://Scenes/HelperScenes/Explosions/EnemyDeathExplosion.tscn")
var point_reward = 400

onready var base_color = modulate
var tags = {"enemy":true}
# Called when the node enters the scene tree for the first time.
func _ready():
	scale *= Settings.get_setting_if_exists(Settings.enemy, "chaser_gen_scale", 1.0)
	point_reward = Settings.get_setting_if_exists(Settings.enemy, "chaser_point_reward", point_reward)
	add_to_group("Enemies")
	add_to_group("Chasers")
	base_health = Settings.get_setting_if_exists(Settings.enemy, "chaser_base_health", base_health) * Settings.get_setting_if_exists(Settings.enemy, "enemy_health_scale", 1.0)
	speed = base_speed * 1/(scale.y)
	health = scale.y * base_health

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(player != null):
		look_at(player.global_position)
		var position_diff = (player.global_position - global_position)
		var position_diff_normalized = position_diff.normalized()
		
		var collision = move_and_collide( position_diff_normalized * speed*delta)
		if(collision != null):
			if(collision.collider.name == player.name):
				player.damage()
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

func take_damage(damage):	
	health -= damage
	$DamageAudio.play()

	$DamageTimer.start()
	var ratio = (base_health-health)/base_health
	modulate.r = ratio
	modulate.g = ratio
	modulate.b = ratio
	
	if(health <= 0):
		die()
	
func die():
	var explosion = death_explosion_scene.instance()
	explosion.position = position
	explosion.point_reward = point_reward
	explosion.scale_mod = scale.x
	get_parent().add_child(explosion)
	queue_free()

func _on_DamageTimer_timeout():
	modulate = base_color
