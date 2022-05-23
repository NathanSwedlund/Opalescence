extends Node2D


export var wait_time = 10.0
var time_left
var is_timing = false
var powerup_name = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("PowerupTimerUIs")
	#start_timer(wait_time)
	
func start_timer(_wait_time):
	visible = true  
	is_timing = true
	wait_time = _wait_time
	time_left = wait_time
	
func stop_timer():
	visible = false  
	is_timing = false
	time_left = 0


func visual_timer_update():
	$VisualTimer.get_material().set_shader_param("value", (time_left/wait_time) * -100 + 100)

func _process(delta):
	if(is_timing):
		time_left -= delta
		visual_timer_update()
		if(time_left <= 0):
			visible = false
			is_timing = false
