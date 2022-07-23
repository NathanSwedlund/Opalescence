extends KinematicBody2D
export var speed = 700
var target = null
var is_exploding = false
export var rot_speed = 15

# Called when the node enters the scene tree for the first time.
func _ready():
	$AudioStreamPlayer2.play()
	if(target != null):
		target = target.normalized()
	else:
		explode()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Sprite.rotate(rot_speed*delta)
	$Sprite2.rotate(rot_speed*delta)
	if (!is_exploding):
		var col = move_and_collide(speed*target*delta)
		if(col != null):
			if(col.collider.is_in_group("Enemies")):
				col.collider.die()
			if(col.collider.is_in_group("Walls")):
				target = null
				explode()
	else:
		$AudioStreamPlayer2.volume_db -= delta * 10
			
func explode():
	if (!is_exploding):
		is_exploding = true
		$AudioStreamPlayer.play()
		$Particles2D2.emitting = true
		$Sprite.visible = false
		$Sprite2.visible = false
		$Timer.stop()
		$Timer.wait_time = 1
		$Timer.start()
	

func _on_Timer_timeout():
	get_parent().queue_free()
	is_exploding = true
