extends Particles2D


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("Particles")
	var particles_count = len(get_tree().get_nodes_in_group("Particles"))
	if(particles_count > 50):
		amount /= (particles_count * 0.05)
	amount *= Global.partical_scales_per_graphical_setting[Settings.saved_settings["graphical_quality"]]
