extends KinematicBody2D

export var speed = 40
export var shrink_scalar = 0.7
export var max_decay_stage = 3
var decay_stage = 0

# Will be set by pointFactory
var player:Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("Points")
	$OuterLight.color = modulate
	$InnerLight.color = modulate

func _process(delta):
	var dist = position.distance_squared_to(player.position)
	if(dist < player.gravity_radius*player.gravity_radius):
		var position_diff = (player.position - position)
		var position_diff_normalized = position_diff.normalized()
		var speed_mod  = 1/( abs(position_diff.x)+abs(position_diff.y) ) * player.gravity_pull_scale
		var move_speed = speed*delta * speed_mod 
		
		var collision = move_and_collide( position_diff_normalized * move_speed)
		if(collision != null):
			if(collision.collider.name == player.name):
				player.gain_point(modulate)
			queue_free()

func decay():
	$InnerLight.scale *= shrink_scalar
	$OuterLight.scale *= shrink_scalar
	$Sprite.scale *= shrink_scalar
	decay_stage += 1
	
	if(decay_stage > max_decay_stage):
		queue_free()
	
func _on_Timer_timeout():
	decay()
