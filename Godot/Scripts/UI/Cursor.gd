extends Node2D

var is_in_controller_mode = false
var cursor_sep_from_player  = 100
var player:Node2D
var mouse_direction_from_player
var mouse_position = Vector2.ZERO
var auto_aim_bias = 0.2
var auto_aim_radius_squared = 700*700
var auto_aim_frame_wait = 3
var auto_aim_is_engaged = false
var current_frame = 0

func _input(event):
	# Mouse in viewport coordinates.
	if (event is InputEventMouseMotion):
		mouse_position = event.position
		mouse_direction_from_player = (mouse_position - player.global_position).normalized()
		position = mouse_direction_from_player * cursor_sep_from_player
		is_in_controller_mode = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

var right_stick_direction
func _process(_delta):
	current_frame += 1
	
	if(not is_in_controller_mode):
		mouse_direction_from_player = (mouse_position - player.global_position).normalized()
		position = mouse_direction_from_player * cursor_sep_from_player
		is_in_controller_mode = false
		if(OS.keep_screen_on == true):
			OS.keep_screen_on = false
		
	
	$Sprite.visible = is_in_controller_mode
	right_stick_direction = Vector2.ZERO
	right_stick_direction.y = Input.get_action_strength("controller_right_stick_down") - Input.get_action_strength("controller_right_stick_up")
	right_stick_direction.x = Input.get_action_strength("controller_right_stick_right") - Input.get_action_strength("controller_right_stick_left")
	var left_stick_direction = Input.get_action_strength("controller_left_stick_down") - Input.get_action_strength("controller_left_stick_up")

	if(left_stick_direction != 0 and is_in_controller_mode == false):
		is_in_controller_mode = true
	

	
	if(right_stick_direction != Vector2.ZERO and is_in_controller_mode):
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		is_in_controller_mode = true
		if(OS.keep_screen_on == false):
			OS.keep_screen_on = true
		
		if(right_stick_direction != Vector2.ZERO and auto_aim_is_engaged == false):
			visible = true
			position = right_stick_direction.normalized() * cursor_sep_from_player

		if(current_frame % auto_aim_frame_wait == 0):
			auto_aim_is_engaged = false
			var enemy_dirs = []
			var current_target = null
			var current_target_dist = INF
			for e in get_tree().get_nodes_in_group("Enemies"):
				var enemy_dist = e.global_position.distance_squared_to(Global.player.global_position)
				var enemy_dir = (e.global_position - player.global_position).normalized()
				var aim_dist = enemy_dir.distance_squared_to(right_stick_direction)
				if(current_target == null or current_target_dist > enemy_dist):
					if(aim_dist < auto_aim_bias and enemy_dist < auto_aim_radius_squared and e.is_in_group("Explosion") == false):
						position = enemy_dir * cursor_sep_from_player
						auto_aim_is_engaged = true
						current_target = e
						current_target_dist = enemy_dist

