extends Node2D

func _ready():
	OS.window_fullscreen = Settings.saved_settings["fullscreen_mode"]
	if(Settings.saved_settings["show_epilepsy_warning"] == false):
		$Label.visible = false
		get_tree().change_scene("res://Scenes/MainScenes/OpeningScene.tscn")
	
func _on_Timer_timeout():
	get_tree().change_scene("res://Scenes/MainScenes/OpeningScene.tscn")
 
