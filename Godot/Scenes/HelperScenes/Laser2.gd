extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var max_fade_in_width = 45
export var particle_intensity_scale = 1.0
export var lifetime = 1.0
func _ready():
	for c in get_children():
		if(c != $LaserSound):
			c.max_fade_in_width = max_fade_in_width
			c.particle_intensity_scale = particle_intensity_scale
			c.lifetime = lifetime
			c._ready()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotation = Vector2.ZERO.angle_to_point(get_parent().get_direction_to_shoot(name))
	modulate = get_parent().modulate
	if(get_child_count() == 1):
		queue_free()

func get_direction_to_shoot(_name):
	if(_name == "Laser2"):
		return Vector2.LEFT.rotated(deg2rad(20))
	if(_name == "Laser3"):
		return Vector2.LEFT.rotated(deg2rad(-20))
	else:
		return Vector2.LEFT

