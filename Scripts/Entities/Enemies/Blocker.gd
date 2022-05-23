extends KinematicBody2D

export var speed = 5
export var health = 150
var death_explosion_scene = load("res://Scenes/HelperScenes/Explosions/EnemyDeathExplosion.tscn")

var point_reward = 3000

var point_to_cover = null
var looking_for_point = true

onready var base_color = modulate

func _ready():
	point_reward = Settings.get_setting_if_exists(Settings.enemy, "blocker_point_reward", point_reward)
	health = Settings.get_setting_if_exists(Settings.enemy, "blocker_health", health)
	add_to_group("Enemies")
	add_to_group("Blockers")

func _physics_process(delta):
	if(point_to_cover != null and is_instance_valid(point_to_cover)):
		var move_direction = position.direction_to(point_to_cover.position)
		var collision = move_and_collide(move_direction*speed, delta)
		if(collision != null):
			if(collision.collider.name == "Player"):
				collision.collider.damage()
			elif(collision.collider.is_in_group("Blockers")):
				die()
				
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


func take_damage(damage, play_sound=true):
	if(play_sound):
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

func _on_DamageTimer_timeout():
	modulate = base_color
