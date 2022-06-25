extends Particles2D


# Called when the node enters the scene tree for the first time.
func _ready():
	amount *= Global.partical_scales_per_graphical_setting[Settings.saved_settings["graphical_quality"]]
