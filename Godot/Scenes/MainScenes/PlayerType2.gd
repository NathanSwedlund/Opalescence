extends Node2D

# Called when the node enters the scene tree for the first time.
var player = null
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(player != null):
		$Light2D.color = player.modulate
	else:
		if( get_parent().player != null):
			player = get_parent().player
			$Light2D.scale *= player.light_size
