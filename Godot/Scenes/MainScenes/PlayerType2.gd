extends Node2D

# Called when the node enters the scene tree for the first time.
var player = null
export var light_scale = 2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(player != null):
		$Light2D.color = player.modulate
		$Light2D.scale = player.find_node("OuterLight").scale*light_scale
	else:
		if( get_parent().player != null):
			player = get_parent().player
			$Light2D.scale *= player.light_size
			$Light2D.visible = true
