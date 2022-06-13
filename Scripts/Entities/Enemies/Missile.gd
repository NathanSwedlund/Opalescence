extends KinematicBody2D

export var speed = 200
export var health = 1
export var damage = 5

export var direction = Vector2.ONE

export var has_explosion = true
var parent_shooter:Node2D
var explosion_scene = load("res://Scenes/HelperScenes/Explosions/EnemyDeathExplosion.tscn")
export var expl_scale = 0.5
var point_reward = 0

func _ready():
	speed  = Settings.get_setting_if_exists(Settings.enemy, "shooter_missile_speed",  speed) * Settings.get_setting_if_exists(Settings.enemy, "shooter_missile_speed_scale",  1.0)
	health = Settings.get_setting_if_exists(Settings.enemy, "shooter_missile_health", health)
	damage = Settings.get_setting_if_exists(Settings.enemy, "shooter_missile_damage", damage)
	
	add_to_group("Enemies")
	add_to_group("Missiles")
		
func _physics_process(delta):
	var collision = move_and_collide(direction*speed*delta)
	if(collision):
		if(collision.collider != parent_shooter):
			if(collision.collider.is_in_group("Enemies") and collision.collider.is_in_group("Blockers") == false):
				collision.collider.take_damage(damage)
			elif(collision.collider.name == "Player"):
				collision.collider.damage()
			die()

func take_damage(damage):
	die()
	
func die():
	if(has_explosion):
		var expl = explosion_scene.instance()
		expl.scale_mod = expl_scale
		expl.point_reward = point_reward
		expl.position = position
		get_parent().add_child(expl)
	
	queue_free()
