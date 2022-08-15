extends Node2D

export var deg_sep = 4
var direction = Vector2.ZERO
var incendiary
var small_bullet_explosion_scene


# Called when the node enters the scene tree for the first time.
func _ready():
	var step = (deg_sep*2)/get_child_count()
	var weight = step
	if(incendiary):
		$AudioStreamPlayer.pitch_scale = Global.player.incendiary_audio_pitch

	$Particles2D.process_material.direction.x = direction.x
	$Particles2D.process_material.direction.y = direction.y
	$Particles2D.emitting = true
	for b in get_children():
		if(b != $AudioStreamPlayer and b != $Particles2D):
			var sep = deg2rad(rand_range(deg_sep,-deg_sep)) #deg2rad(move_toward(deg_sep, -deg_sep, weight))
			weight += step
			b.rotate(sep)
			b.direction = direction.rotated(sep)

			b.set_incendiary(incendiary)
			b.small_bullet_explosion_scene = small_bullet_explosion_scene

func _on_AudioStreamPlayer_finished():
	$AudioStreamPlayer.queue_free()

func _process(delta):
	modulate = Global.player.modulate
