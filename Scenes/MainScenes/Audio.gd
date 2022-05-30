extends AudioStreamPlayer

export var default_vol = 0.0
export var is_music = false


# Called when the node enters the scene tree for the first time.
func _ready():
	if(is_music):
		add_to_group("Music")
	else:
		add_to_group("FX")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
