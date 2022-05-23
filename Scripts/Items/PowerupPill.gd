extends KinematicBody2D

export var speed = 40
export var rot_speed = 0.1

# Will be set by pointFactory
var player:Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("Powerups")
	$OuterLight.color = get_parent().modulate
	$InnerLight.color = get_parent().modulate
	
func _process(delta):
	rotate(rot_speed)
	var dist = global_position.distance_squared_to(player.position)
	if(dist < player.gravity_radius*player.gravity_radius):
#		print("move")
		var position_diff = (player.position - global_position)
		var position_diff_normalized = position_diff.normalized()
		var speed_mod  = 1/( abs(position_diff.x)+abs(position_diff.y) ) * player.gravity_pull_scale
		var move_speed = speed*delta * speed_mod
		
		var collision = move_and_collide( position_diff_normalized * move_speed)
		if(collision != null):
			if(collision.collider.name == player.name):
				player.get_powerup(get_parent().name, get_parent().modulate)
				get_parent().queue_free()
