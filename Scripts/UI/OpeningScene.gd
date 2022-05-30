extends Node2D

export var text = "OPALESCENCE"
export var pitch_change_per_char = -0.015

var current_char_index = 0
var chars_appearing = true

export var destination_scale = Vector2(0.7, 0.7)
export var destination_position = Vector2(0, -80)
var move_speed
var scale_speed

# Called when the node enters the scene tree for the first time.
func _ready():
	if(Settings.saved_settings["show_intro"] == false):
		$LabelContainer.visible = false
		get_tree().change_scene("res://Scenes/MainScenes/MainMenu.tscn")
	
	move_speed = ($LabelContainer.position.y - destination_position.y)/$WaitTimer.wait_time
	scale_speed = ($LabelContainer.scale.y - destination_scale.y)/$WaitTimer.wait_time
	
	$LabelContainer/Label.text = ""
	OS.window_fullscreen = Settings.saved_settings["fullscreen_mode"]

	
func _on_CharTimer_timeout():
	$LabelContainer/Label.text += text[current_char_index]
	$LabelContainer/Label.modulate = Settings.saved_settings["colors"][current_char_index%len(Settings.saved_settings["colors"])]
	current_char_index += 1
	$CharAppears.play()
	$CharAppears.pitch_scale += pitch_change_per_char
	
	if($LabelContainer/Label.text  == text):
		$Particles2D.emitting = true
		$CharsFinished.play()
		$LabelContainer/Label.modulate = Color.white
		chars_appearing = false
		$CharTimer.stop()
		$WaitTimer.start()

func _on_WaitTimer_timeout():
	get_tree().change_scene("res://Scenes/MainScenes/MainMenu.tscn")

func _process(delta):
	if(!chars_appearing):
		$LabelContainer.scale.x = move_toward($LabelContainer.scale.x, destination_scale.x, scale_speed*delta)
		$LabelContainer.scale.y = move_toward($LabelContainer.scale.y, destination_scale.y, scale_speed*delta)
		$LabelContainer.position.x = move_toward($LabelContainer.position.x, destination_position.x, move_speed*delta)
		$LabelContainer.position.y = move_toward($LabelContainer.position.y, destination_position.y, move_speed*delta)
