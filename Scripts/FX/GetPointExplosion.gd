extends Particles2D

# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.wait_time = lifetime
	$Timer.start()

func _on_Timer_timeout():
	queue_free()
