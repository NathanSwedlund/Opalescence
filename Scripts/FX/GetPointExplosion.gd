extends Particles2D

# Called when the node enters the scene tree for the first time.
func _ready():
	$AudioStreamPlayer.volume_db = $AudioStreamPlayer.default_vol + Settings.saved_settings["fx_volume"]
	$Timer.wait_time = lifetime
	$Timer.start()

func _on_Timer_timeout():
	queue_free()
