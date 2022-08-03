extends Node2D

func _ready():
	for s in $Shooters.get_children():
		s.missiles_have_explosion = false
		
func _process(delta):
	if($Shooters.get_child_count() == 0):
		get_parent().boss_fight_completed()
		
func pause_shooting(time):
	$PauseShootingTimer.wait_time = time
	$PauseShootingTimer.start()
	for s in $Shooters.get_children():
		if(s.is_in_group("Shooters")):
			s.can_shoot = false

func _on_PauseShootingTimer_timeout():
	for s in $Shooters.get_children():
		if(s.is_in_group("Shooters")):
			s.can_shoot = true

func take_damage(damage, play_sound=true, color_override=null):
	pass
