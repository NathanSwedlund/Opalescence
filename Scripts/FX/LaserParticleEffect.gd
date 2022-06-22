extends Particles2D

func _ready():
		amount *= Global.partical_scales_per_graphical_setting[Settings.saved_settings["graphical_quality"]]

func _process(_delta):
	scale = Vector2.ONE/get_parent().scale
