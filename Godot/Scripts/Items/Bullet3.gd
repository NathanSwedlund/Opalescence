extends KinematicBody2D

var direction = Vector2.ZERO
export var speed = 0
export var speed_accel = 500.0
export var speed_accel_scale = 3
var speed_max = 5000.0

export var base_damge = 2.0
var damage_mod = 1.0
var incendiary = false

var small_bullet_explosion_scene 
export var explosion_scale = 0.3
func _ready():
	small_bullet_explosion_scene = load("res://Scenes/HelperScenes/Explosions/EnemyDeathExplosion.tscn")
	base_damge *= Settings.player["bullet_damage_scale"]
	if(incendiary):
		speed_accel *= 2.2
		damage_mod = 3
		scale *= 2.2
	$Sprite.rotate((Vector2.ZERO).angle_to_point(direction))
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	speed *= 1+(speed_accel_scale*delta)
	if(speed < speed_max):
		speed += delta * speed_accel
		
	modulate = Global.player.modulate
	var collision = move_and_collide(direction*speed*delta, delta)
	if(collision != null):
		var speed_ratio = speed/speed_max
		if(collision.collider.is_in_group("Enemies")):
			collision.collider.take_damage(base_damge*damage_mod * speed_ratio)
		
		var explosion = small_bullet_explosion_scene.instance()
		explosion.position = position
		explosion.scale_mod = explosion_scale * speed_ratio  * scale.x
		explosion.explosion_pitch = 1.5-speed_ratio
		if(incendiary):
			explosion.scale_mod *= 3
		explosion.rotation = $Sprite.rotation
		explosion.grow_speed = 1.17
		explosion.shrink_speed = 0.93
		explosion.modulate = modulate
		
			
		get_parent().add_child(explosion)
		queue_free()
