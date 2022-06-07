extends Area2D

export var min_fade_out_width = 0.05
var is_fading_in = true

export var max_fade_in_width = 30

var total_time = 1.5
var fade_in_time_ratio = 0.35
var not_fading_time = 0.55
var fade_out_time_ratio = 0.1

export var damage = 30
export var fade_out_speed = 1.1
export var fade_in_speed = 2.0

export var particle_intensity_scale = 1.0

export var min_vol = -40
export var laser_sound_fade_scale = 3
var laser_vol

var frames_per_damage = 7
var current_frame = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	damage *= Settings.shop["laser_damage_scale"]

	laser_vol = $LaserSound.volume_db
	$LaserSound.volume_db = min_vol
	
	if(particle_intensity_scale != 1.0):
		$LaserParticleEffect.lifetime *= particle_intensity_scale/1.5
		$LaserParticleEffect.amount *= particle_intensity_scale*3

	$FadeInTimer.wait_time = fade_in_time_ratio * total_time
	$FadeOutTimer.wait_time = fade_out_time_ratio * total_time
	$NotFadingTimer.wait_time = not_fading_time * total_time

	$FadeInTimer.start()

	add_to_group("Lasers")

	$Light2D.color = get_parent().modulate

	$LaserParticleEffect.emitting = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	rotation = Vector2.ZERO.angle_to_point(get_parent().get_direction_to_shoot())
	
	if(is_fading_in):
		if(scale.y < max_fade_in_width):
			scale.y += fade_in_speed * (1-fade_in_time_ratio) * _delta
			$LaserSound.volume_db = move_toward($LaserSound.volume_db, laser_vol, fade_in_speed * (1-fade_in_time_ratio) * _delta * laser_sound_fade_scale)
		else:
			scale.y = max_fade_in_width
	else:
		if(scale.y > min_fade_out_width):
			scale.y -= fade_out_speed * (1-fade_out_time_ratio) * _delta
			$LaserSound.volume_db = move_toward($LaserSound.volume_db, min_vol, fade_out_speed * (1-fade_out_time_ratio) * _delta * laser_sound_fade_scale)
		if(scale.y <= 0.0):
			queue_free()
	
	current_frame = (current_frame + 1) % frames_per_damage
	if(current_frame == 0):
		for i in get_overlapping_bodies():
			if(i.is_in_group("Enemies")):
				i.take_damage(damage * _delta * frames_per_damage)

func _on_FadeInTimer_timeout():
	$NotFadingTimer.start()

func _on_NotFadingTimer_timeout():
	is_fading_in = false
	$FadeOutTimer.start()

func _on_FadeOutTimer_timeout():
	queue_free()
