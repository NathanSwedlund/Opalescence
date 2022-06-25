extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var shift_speed = 1
var target_color
var colors = Settings.get_setting_if_exists(Settings.saved_settings, "colors", [Color.white])
# Called when the node enters the scene tree for the first time.
func _ready():
	target_color = colors[randi()%len(colors)]

func _process(delta):
	modulate.r = move_toward(modulate.r, target_color.r, shift_speed * delta)
	modulate.g = move_toward(modulate.g, target_color.g, shift_speed * delta)
	modulate.b = move_toward(modulate.b, target_color.b, shift_speed * delta)
	
	if(modulate == target_color):
		target_color = colors[randi()%len(colors)]
