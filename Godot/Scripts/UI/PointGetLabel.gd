extends Node2D

export var points_num = 0
export var speed = 2
export var max_move_up = 20
export var color = Color.white
var amount_moved = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if(Global.player.can_collect_points == false):
		queue_free()
		
	points_num *=  Settings.world["points_scale"]
	$Label.modulate = color
	$Label.text = Global.point_num_to_string(Global.round_float(points_num, 0), ["b", "m", "k"]) #+ "pts"
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	amount_moved += speed
	if(amount_moved <= max_move_up):
		position.y -= speed

func _on_Timer_timeout():
	queue_free()
