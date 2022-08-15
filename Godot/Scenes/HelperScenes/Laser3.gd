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
export var lifetime = 0.15


# Called when the node enters the scene tree for the first time.
func _ready():
	Global.shakes["laser"].start(max_fade_in_width/10.0, total_time*0.8, 200)

	if(Settings.world["is_mission"] == false):
		damage *= Settings.shop["laser_damage_scale"]


	if(particle_intensity_scale != 1.0):
		$LaserParticleEffect.lifetime *= particle_intensity_scale/1.5
		$LaserParticleEffect.amount *= particle_intensity_scale*3


	add_to_group("Lasers")

	$Light2D.color = get_parent().modulate
	$LaserDestroyTimer.wait_time = lifetime
	$LaserDestroyTimer.start()
	$DeleteTimer.wait_time += lifetime
	$DeleteTimer.start()
	$LaserParticleEffect.emitting = true
	Global.vibrate_controller(total_time,0.3,0,1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	rotation = Vector2.ZERO.angle_to_point(get_parent().get_direction_to_shoot(name))
	if(is_fading_in):
		if(scale.y < max_fade_in_width):
			scale.y += fade_in_speed * (1-fade_in_time_ratio) * _delta
		else:
			scale.y = max_fade_in_width
	else:
		if(scale.y > min_fade_out_width):
			scale.y -= fade_out_speed * (1-fade_out_time_ratio) * _delta
		if(scale.y <= 0.0):
			queue_free()

	for i in get_overlapping_bodies():
		if(i.is_in_group("Enemies")):
			i.take_damage(damage * _delta)

func _on_DeleteTimer_timeout():
	queue_free()

func _on_LaserDestroyTimer_timeout():
	for c in get_children():
		if( (c in [$LaserSound, $LaserSound2, $DeleteTimer]) == false):
			c.queue_free()
