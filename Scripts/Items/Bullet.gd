extends KinematicBody2D

var direction = Vector2.ZERO
export var speed = 700

var base_damge = 2
var damage_mod = 1
var incendiary = false

var small_bullet_explosion_scene
func _ready():
	if(incendiary):
		speed *= 2
		damage_mod = 2
		scale *= 2
	$Sprite.rotate((Vector2.ZERO).angle_to_point(direction))
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var collision = move_and_collide(direction*speed*delta, delta)
	if(collision != null):
		if(collision.collider.is_in_group("Enemies") and collision.collider.is_in_group("Blockers") == false):
			collision.collider.take_damage(base_damge*damage_mod)
		if(collision.collider.is_in_group("Blockers")):
			Global.player.find_node("SoundFX").find_node("BulletHitFail").play()
			
		
		var explosion = small_bullet_explosion_scene.instance()
		explosion.position = position
		explosion.modulate = modulate
		
		if(incendiary):
			explosion.get_node("Particles2D").amount *= 10
			
		get_parent().add_child(explosion)
		queue_free()
		
