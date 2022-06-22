extends Node

const TRANS = Tween.TRANS_SINE
const EASE = Tween.EASE_IN_OUT

var amplitude = 0
var priority = 0

onready var camera = get_parent()
export var shake_name = ""

func _ready():
	Global.shakes[shake_name] = self

func start(amplitude = 3, duration = 0.1, Freq = 20, priority = 0):
	if (priority >= self.priority):
		self.priority = priority
		self.amplitude = amplitude

		$Duration.wait_time = duration
		$Freq.wait_time = 1 / float(Freq)
		$Duration.start()
		$Freq.start()

		_new_shake()

func _new_shake():
	var rand = Vector2()
	rand.x = rand_range(-amplitude, amplitude)
	rand.y = rand_range(-amplitude, amplitude)

	$Tween.interpolate_property(camera, "offset", camera.offset, rand, $Freq.wait_time, TRANS, EASE)
	$Tween.start()

func _reset():
	$Tween.interpolate_property(camera, "offset", camera.offset, Vector2(), $Freq.wait_time, TRANS, EASE)
	$Tween.start()
	priority = 0

func _on_Duration_timeout():
	_reset()
	$Freq.stop()

func _on_Freq_timeout():
	_new_shake()
