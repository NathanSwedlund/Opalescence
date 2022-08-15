extends KinematicBody2D

export var min_fade_out_width = 0.05
var is_fading_in = true

export var max_fade_in_width = 30

var total_time = 1.5
var fade_in_time_ratio = 0.35
var not_fading_time = 0.55
var fade_out_time_ratio = 0.1

export var damage = 40
export var fade_out_speed = 1.1
export var fade_in_speed = 2.0

export var particle_intensity_scale = 1.0

export var min_vol = -40
export var laser_sound_fade_scale = 3
var laser_vol
export var lifetime = 0.15
export var ball_speed = 1000
var current_dir
var init_scale
# Called when the node enters the scene tree for the first time.
func _ready():
	init_scale = scale
	current_dir = Global.player.get_direction_to_shoot()
	Global.shakes["laser"].start(max_fade_in_width/10.0, total_time*0.8, 200)

	if(Settings.world["is_mission"] == false):
		damage *= Settings.shop["laser_damage_scale"]

	if(particle_intensity_scale != 1.0):
		$LaserParticleEffect.lifetime *= particle_intensity_scale/1.5
		$LaserParticleEffect.amount *= particle_intensity_scale*3

	add_to_group("Lasers")
	$DeleteTimer.wait_time = lifetime
	$DeleteTimer.start()
	$LaserParticleEffect.emitting = true
	Global.vibrate_controller(lifetime,0.3,0,1)

	$Bomb.add_to_group("Lasers")
	$Bomb/PowerupPill.explode()
	$Bomb/PowerupPill.damage = damage
	$Bomb/PowerupPill.shrink_speed = 0
	$AudioTween.interpolate_property($LaserSound2, "volume_db", $LaserSound2.volume_db, $LaserSound2.volume_db-6, lifetime/4)
	$AudioTween.interpolate_property($LaserSound2, "pitch_scale", $LaserSound2.pitch_scale, $LaserSound2.pitch_scale-0.5, lifetime/4)
	$AudioTween.interpolate_property($LaserSound, "pitch_scale", $LaserSound.pitch_scale, $LaserSound.pitch_scale-0.5, lifetime)
	$AudioTween.interpolate_property($LaserSound, "volume_db", $LaserSound.volume_db, -10, lifetime, $AudioTween.TRANS_EXPO)
	$AudioTween.start()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	modulate = Global.player.modulate
	var collision = move_and_collide(current_dir*ball_speed*delta, delta)
	if(collision != null):
		if(collision.collider.is_in_group("Walls")):
#			$LaserSound2.play()

			if(collision.collider.name in ["TopWall", "BottomWall"]):
				current_dir.y *= -1
			else: # right or left wall
				current_dir.x *= -1

	scale = init_scale * ($DeleteTimer.time_left/$DeleteTimer.wait_time)

func _on_DeleteTimer_timeout():
	queue_free()

