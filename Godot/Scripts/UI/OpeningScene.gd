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
	for i in range($FadeInLabels.get_child_count()):
		$FadeInLabels.get_child(i).modulate = Settings.saved_settings["colors"][i%len(Settings.saved_settings["colors"])]
		$FadeInLabels.get_child(i).modulate.a = 0.0

	if(Settings.saved_settings["show_intro"] == false):
		$LabelContainer.visible = false
		get_tree().change_scene("res://Scenes/MainScenes/MainMenu.tscn")

	move_speed = ($LabelContainer.position.y - destination_position.y)/$WaitTimer.wait_time
	scale_speed = ($LabelContainer.scale.y - destination_scale.y)/$WaitTimer.wait_time

	OS.window_fullscreen = Settings.saved_settings["fullscreen_mode"]

var first_char_timer_pass = true
func _on_CharTimer_timeout():
	if(first_char_timer_pass):
		first_char_timer_pass = false
		return
	if(current_char_index  == len("OPALESCENCE")):
		$FadeInLabels.visible = false
		$LabelContainer/Label.visible = true
		$Particles2D.emitting = true
		$CharsFinished.play()
		$LabelContainer/Label.modulate = Color.white
		if(Settings.shop["monocolor_color"] != null):
			$LabelContainer/Label.modulate = Settings.shop["monocolor_color"]
			$Particles2D.modulate = Settings.shop["monocolor_color"]
			$Particles2D2.modulate = Settings.shop["monocolor_color"]
		chars_appearing = false
		$CharTimer.stop()
		$WaitTimer.start()
		return

	$FadeInLabels.get_child(current_char_index).fade_in()
	$CharAppears.play()
	$CharAppears.pitch_scale += pitch_change_per_char
	current_char_index += 1

func _on_WaitTimer_timeout():
	get_tree().change_scene("res://Scenes/MainScenes/MainMenu.tscn")

func _process(delta):
	if(!chars_appearing):
		$LabelContainer.scale.x = move_toward($LabelContainer.scale.x, destination_scale.x, scale_speed*delta)
		$LabelContainer.scale.y = move_toward($LabelContainer.scale.y, destination_scale.y, scale_speed*delta)
		$LabelContainer.position.x = move_toward($LabelContainer.position.x, destination_position.x, move_speed*delta)
		$LabelContainer.position.y = move_toward($LabelContainer.position.y, destination_position.y, move_speed*delta)

	if(Input.is_action_just_pressed("ui_cancel") or Input.is_action_just_pressed("ui_accept")):
		get_tree().change_scene("res://Scenes/MainScenes/MainMenu.tscn")
