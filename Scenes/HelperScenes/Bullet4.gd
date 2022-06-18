extends Node2D

export var deg_sep = 4
var direction = Vector2.ZERO
var incendiary
var small_bullet_explosion_scene


# Called when the node enters the scene tree for the first time.
func _ready():
	var step = (deg_sep*2)/get_child_count()
	var weight = step
	for b in get_children():
		var sep = deg2rad(move_toward(deg_sep, -deg_sep, weight))
		weight += step
		b.rotate(sep)
		b.direction = direction.rotated(sep)
		
		b.incendiary = incendiary
		b.small_bullet_explosion_scene = small_bullet_explosion_scene
	
	
