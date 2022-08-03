extends Label

export var bounciness_scale = 1.0
export var bounce_on_change = true
export var bounce_amount = 10
export var bounce_time = 0.02
export var bounce_up_first = false
export var play_audio_on_bounce = false
var bouncing = false
var last_value


# Called when the node enters the scene tree for the first time.
func _ready():
	bounce_amount *= bounciness_scale
	last_value = text

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if(text != last_value and bounce_on_change):
		last_value = text
		bounce()
		
func bounce():
	if(bouncing == true):
		return
		
	if(play_audio_on_bounce):
		$AudioStreamPlayer.play()
	bouncing = true
	
	print("bouncing")
	if(bounce_up_first):
		bounce_up()
	else:
		bounce_down()
	

func bounce_up():
	var tween = get_node("UpTween")
	tween.interpolate_property(self, "margin_top",
		margin_top, margin_top - bounce_amount, bounce_time,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	
func bounce_down():
	var tween = get_node("DownTween")
	tween.interpolate_property(self, "margin_top",
		margin_top, margin_top + bounce_amount, bounce_time,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

func _on_UpTween_tween_all_completed():
	if(bounce_up_first):
		bounce_down()
	else:
		bouncing = false

func _on_DownTween_tween_all_completed():
	if(bounce_up_first == false):
		bounce_up()
	else:
		bouncing = false
