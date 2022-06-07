extends KinematicBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var rot_speed = 20
export var scale_speed = Vector2(6, 6)
export var scale_max = 1.5
export var scale_min = 0.75
export var explosion_scale = 1.5
var growing = true
var exploding = false
var damage = 40

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var frames_per_update = 7
var current_frame = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(exploding == false):
		rotate(rot_speed * delta)
		if(growing):
			scale = scale + scale_speed * delta
		else:
			scale = scale - scale_speed * delta

		if(scale.x > scale_max and growing):
			growing = false
		if(scale.x < scale_min and ! growing):
			growing = true

		var collision = move_and_collide( Vector2(0.001,0.001))
		if(collision != null):
			if(collision.collider.is_in_group("Enemies")):
				explode()
	else:
		current_frame = (current_frame + 1) % frames_per_update
		if(current_frame == 0):
			for i in get_parent().find_node("Area2D").get_overlapping_bodies():
				if(i.is_in_group("Enemies")):
					i.take_damage(damage * delta * frames_per_update)

func explode():
	if(exploding):
		return

	$ExplosionParticles.emitting = true
	exploding = true
	$AudioStreamPlayer.play()
	$ExplosionTimer.start()
	$OuterLight.scale *= 12
	$InnerLight.energy *= 1.9
	$InnerLight.scale *= 9
	$InnerLight.energy *= 1.4
	$Sprite.visible = false

func change_color(color):
	modulate = color
	$OuterLight.color = color
	$InnerLight.color = color

func _on_CountdownTimer_timeout():
	explode()

func _on_ExplosionTimer_timeout():
	get_parent().queue_free()
