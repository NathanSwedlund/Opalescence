extends KinematicBody2D

var direction = Vector2.ZERO
export var speed = 700

export var base_damge = 2.0
var damage_mod = 1.0
var incendiary = false

var small_bullet_explosion_scene
var damaged_enemies = []
func _ready():
	base_damge *= Settings.player["bullet_damage_scale"]

	if(incendiary):
		$AudioStreamPlayer.pitch_scale = Global.player.incendiary_audio_pitch
		speed *= 2.2
		damage_mod = 3
		scale *= 2.2
	$Sprite.rotate((Vector2.ZERO).angle_to_point(direction))
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	modulate = Global.player.modulate
	var collision = move_and_collide(direction*speed*delta, delta)
	if(collision != null):
		if(collision.collider.is_in_group("Enemies") and (collision.collider in damaged_enemies) == false):
			damaged_enemies.append(collision.collider)
			add_collision_exception_with(collision.collider)
			
			if( collision.collider.is_in_group("Blockers") == false or incendiary):
				collision.collider.take_damage(base_damge*damage_mod)
				Global.entity_effects[collision.collider] = "poison" 
			if(collision.collider.is_in_group("Blockers") and !incendiary):
				Global.player.find_node("SoundFX").find_node("BulletHitFail").play()
			queue_free()	
			
		if(collision.collider.is_in_group("Enemies") == false):
			var explosion = small_bullet_explosion_scene.instance()
			explosion.position = position
			explosion.rotation = $Sprite.rotation
			explosion.modulate = modulate
		
			if(incendiary):
				explosion.get_node("Particles2D").amount *= 10
				
			get_parent().add_child(explosion)
			queue_free()


func _on_AudioStreamPlayer_finished():
	$AudioStreamPlayer.queue_free()
