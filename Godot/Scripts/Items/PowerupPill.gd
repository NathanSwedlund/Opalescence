extends KinematicBody2D

export var speed = 40
export var rot_speed = 6
export var is_powerup = true
var powerup_name
# Will be set by pointFactory
var player:Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	powerup_name = get_parent().name
	if(is_powerup):
		print("Loading ", "res://Resources/Textures/Items/"+powerup_name+" Icon.png")
		$IconSprite.texture = load("res://Resources/Textures/Items/"+powerup_name+" Icon.png")
	else:
		$IconSprite.visible = false
		
	add_to_group("Powerups")
	$OuterLight.color = get_parent().modulate
	$InnerLight.color = get_parent().modulate

func _process(delta):
	rotate(rot_speed*delta)
#	if(is_powerup):
#		$IconSprite.rotate(-rot_speed*delta)
	if(player != null):
		var dist = global_position.distance_squared_to(player.global_position)
		if(dist < player.gravity_radius*player.gravity_radius):
			var position_diff = (player.global_position - global_position)
			var position_diff_normalized = position_diff.normalized()
			var speed_mod  = 1/( abs(position_diff.x)+abs(position_diff.y) ) * player.gravity_pull_scale
			var move_speed = speed*delta * speed_mod

			var collision = move_and_collide( position_diff_normalized * move_speed)
			if(collision != null):
				if(collision.collider.name == player.name):
					player.get_powerup(get_parent().name, get_parent().modulate)
					get_parent().queue_free()
	else:
		player = Global.player
