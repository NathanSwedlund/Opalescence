extends Node2D

var shift_speed = 1
var target_color
var colors = Settings.get_setting_if_exists(Settings.saved_settings, "colors", [Color.white])

func _ready():
	target_color = colors[randi()%len(colors)]

func _process(delta):
	modulate.r = move_toward(modulate.r, target_color.r, shift_speed * delta)
	modulate.g = move_toward(modulate.g, target_color.g, shift_speed * delta)
	modulate.b = move_toward(modulate.b, target_color.b, shift_speed * delta)

	if(modulate == target_color):
		target_color = colors[randi()%len(colors)]

	if($KinematicBody2D/InnerLight != null):
		$KinematicBody2D/InnerLight.color = modulate
	if($KinematicBody2D/OuterLight != null):
		$KinematicBody2D/OuterLight.color = modulate

	if($PowerupPill/InnerLight != null):
		$PowerupPill/InnerLight.color = modulate
	if($PowerupPill/OuterLight != null):
		$PowerupPill/OuterLight.color = modulate


