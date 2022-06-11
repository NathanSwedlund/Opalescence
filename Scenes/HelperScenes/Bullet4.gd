extends Node2D

export var deg_sep = 4
var direction = Vector2.ZERO
var incendiary
var small_bullet_explosion_scene


# Called when the node enters the scene tree for the first time.
func _ready():
	$Bullet.rotate(deg2rad(deg_sep))
	$Bullet.incendiary = incendiary
	$Bullet.direction = direction.rotated(deg2rad(deg_sep))
	$Bullet.small_bullet_explosion_scene = small_bullet_explosion_scene
	
	$Bullet2.incendiary = incendiary
	$Bullet2.direction = direction
	$Bullet2.small_bullet_explosion_scene = small_bullet_explosion_scene
	
	$Bullet3.rotate(-deg2rad(deg_sep))
	$Bullet3.incendiary = incendiary
	$Bullet3.direction = direction.rotated(deg2rad(-deg_sep))
	$Bullet3.small_bullet_explosion_scene = small_bullet_explosion_scene
	
