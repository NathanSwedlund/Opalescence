extends Label


export var visible_time = 2.0
export var fade_speed = 0.01

var should_be_fading = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.wait_time = visible_time
	$Timer.start()
	
func _process(_delta):
	if(should_be_fading):
		modulate.a -= fade_speed
		if(modulate.a <= 0):
			should_be_fading = false

func show_powerup(powerup_name):	
	should_be_fading = false
	$Timer.stop()
	text = powerup_name
	modulate = get_parent().get_parent().modulate
	$Timer.start()
	
func _on_Timer_timeout():
	should_be_fading = true
