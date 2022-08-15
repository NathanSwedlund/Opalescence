extends KinematicBody2D

var direction = Vector2.ZERO
export var speed = 700
export var speed_accel = 1500.0
var speed_max = 1500.0

export var base_damge = 2.0
var damage_mod = 1.0
var incendiary = false

var small_bullet_explosion_scene
export var explosion_scale = 0.5
func _ready():
#	small_bullet_explosion_scene = load("res://Scenes/HelperScenes/Explosions/EnemyDeathExplosion.tscn")
	base_damge *= Settings.player["bullet_damage_scale"]
	$Sprite.rotate((Vector2.ZERO).angle_to_point(direction))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(speed < speed_max):
		speed += delta * speed_accel


	var collision = move_and_collide(direction*speed*delta, delta)
	if(collision != null):
		var speed_ratio = speed/speed_max
		if(collision.collider.is_in_group("Enemies") and collision.collider.is_in_group("Blockers") == false):
			collision.collider.take_damage(abs(base_damge*damage_mod * speed_ratio))
		if(collision.collider.is_in_group("Blockers") and !incendiary):
			Global.player.find_node("SoundFX").find_node("BulletHitFail").play()
		if(collision.collider.is_in_group("Blockers") and incendiary):
			collision.collider.take_damage(abs(base_damge*damage_mod * speed_ratio))

		var explosion = small_bullet_explosion_scene.instance()
		explosion.position = position
		explosion.rotation = $Sprite.rotation
		explosion.modulate = modulate


		get_parent().add_child(explosion)
		queue_free()


func set_incendiary(_incendiary):
	incendiary = _incendiary
	if(incendiary):
		speed *= 2.2
		scale *= 2.2
