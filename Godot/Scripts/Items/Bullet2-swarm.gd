extends KinematicBody2D

var direction = Vector2.ZERO
export var speed = 700

export var base_damge = 2.0
var damage_mod = 1.0
var incendiary = false

var small_bullet_explosion_scene
var target = null
export var heat_seeking_turn_speed = 0.04

func _ready():
	base_damge *= Settings.shop["bullet_damage_scale"]

	if(incendiary):
		speed *= 2.2
		damage_mod = 3
		scale *= 2.2
	$Sprite.rotate((Vector2.ZERO).angle_to_point(direction))
	
func update_target():
	for e in get_tree().get_nodes_in_group("Enemies"):
		if(target == null):
			target = e
		elif(is_instance_valid(target) == false):
			target = e
		elif(position.distance_squared_to(e.position) < position.distance_squared_to(target.position)):
			target = e

# Called every frame. 'delta' is the elapsed time since the previous frame.
var seconds_to_update_target = 0.5
var current_time = 0.0
var time_to_first_target_lock = 0.1
var first_target_has_been_locked = false
var heat_seeking_turn_speed_mod = 0.5
func _process(delta):
	modulate = Global.player.modulate
	current_time += delta
	if(first_target_has_been_locked == false and current_time > time_to_first_target_lock):
		first_target_has_been_locked = true
		update_target()
		
	if(current_time > seconds_to_update_target):
		current_time = 0.0
		update_target()
		
	if(is_instance_valid(target)):
		heat_seeking_turn_speed += delta+heat_seeking_turn_speed_mod
		rotation = move_toward(rotation, get_angle_to(target.position), heat_seeking_turn_speed)
		direction = direction.slerp(position.direction_to(target.position), heat_seeking_turn_speed)
		
	var collision = move_and_collide(direction*speed*delta, delta)
	if(collision != null):
		if(collision.collider.is_in_group("Enemies")):
			if( collision.collider.is_in_group("Blockers") == false or incendiary):
				collision.collider.take_damage(base_damge*damage_mod)
		if(collision.collider.is_in_group("Blockers") and !incendiary):
			Global.player.find_node("SoundFX").find_node("BulletHitFail").play()
		
		var explosion = small_bullet_explosion_scene.instance()
		explosion.position = position
		explosion.rotation = $Sprite.rotation
		explosion.modulate = modulate
		
		if(incendiary):
			explosion.get_node("Particles2D").amount *= 10
			
		get_parent().add_child(explosion)
		queue_free()
