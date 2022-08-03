extends AudioStreamPlayer

export var default_vol = 0.0
export var is_music = false

# Called when the node enters the scene tree for the first time.
func _ready():	
	if(is_music):
		add_to_group("Music")
		if(Settings.saved_settings["music_volume"] == 0):
			volume_db = -80
		else:
			volume_db = default_vol + Settings.saved_settings["music_volume"]/3 + Settings.min_vol
	else:
		add_to_group("FX")
		if(Settings.saved_settings["fx_volume"] == 0):
			volume_db = -80
		else:
			volume_db = default_vol + Settings.saved_settings["fx_volume"]/3 + Settings.min_vol
