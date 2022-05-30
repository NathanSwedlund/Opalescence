extends Node2D

var is_in_controller_mode = false
var cursor_sep_from_player  = 100
var player:Node2D
var mouse_direction_from_player
var mouse_position = Vector2.ZERO

func _input(event):
	# Mouse in viewport coordinates.
	if (event is InputEventMouseMotion):
		mouse_position = event.position
		mouse_direction_from_player = (mouse_position - player.global_position).normalized()
		position = mouse_direction_from_player * cursor_sep_from_player
		is_in_controller_mode = false


var right_stick_direction
func _process(_delta):
	if(not is_in_controller_mode):
		mouse_direction_from_player = (mouse_position - player.global_position).normalized()
		position = mouse_direction_from_player * cursor_sep_from_player
		is_in_controller_mode = false
	
	
	$Sprite.visible = is_in_controller_mode
	right_stick_direction = Vector2.ZERO
	right_stick_direction.y = Input.get_action_strength("controller_right_stick_down") - Input.get_action_strength("controller_right_stick_up")
	right_stick_direction.x = Input.get_action_strength("controller_right_stick_right") - Input.get_action_strength("controller_right_stick_left")
	if(right_stick_direction != Vector2.ZERO or is_in_controller_mode):
		is_in_controller_mode = true
		
		if(right_stick_direction != Vector2.ZERO):
#			position = Vector2.UP * cursor_sep_from_player
#			visible = false
#		else:
			visible = true
			position = right_stick_direction.normalized() * cursor_sep_from_player



