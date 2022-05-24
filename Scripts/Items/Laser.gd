extends Area2D

export var min_fade_out_width = 0.05
var is_fading_in = true

export var max_fade_in_width = 30

var total_time = 1.5
var fade_in_time_ratio = 0.25
var not_fading_time = 0.55
var fade_out_time_ratio = 0.2

export var damage = 30
export var fade_out_speed = 0.88
export var fade_in_speed = 1.56

# Called when the node enters the scene tree for the first time.
func _ready():
	$FadeInTimer.wait_time = fade_in_time_ratio * total_time
	$FadeOutTimer.wait_time = fade_out_time_ratio * total_time
	$NotFadingTimer.wait_time = not_fading_time * total_time
	
	$FadeInTimer.start()
	
	add_to_group("Lasers")
	$Light2D.color = get_parent().modulate

	$LaserParticleEffect.emitting = true
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	print(total_time)
	rotation = Vector2.ZERO.angle_to_point(get_parent().get_direction_to_shoot())
	#print((Vector2.ZERO).angle_to_point(get_parent().mouse_direction_from_player))
	
	if(is_fading_in):
		if(scale.y < max_fade_in_width):
			scale.y *= fade_in_speed
			is_fading_in = false
	else:
		if(scale.y > min_fade_out_width):
			scale.y *= fade_out_speed
			
	for i in get_overlapping_bodies():
		i.take_damage(damage * _delta)

func _on_FadeInTimer_timeout():
	$NotFadingTimer.start()

func _on_NotFadingTimer_timeout():
	is_fading_in = false
	$FadeOutTimer.start()

func _on_FadeOutTimer_timeout():
	queue_free()

