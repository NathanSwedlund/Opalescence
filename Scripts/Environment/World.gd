extends Node2D

export var point_multiplier = 1.0
export var game_is_over = false

# Countdown variables
var countdown_fade_speed = 1
var countdown_amount = 3
var countdown_is_over = false
var countdown_current_value = countdown_amount

func game_over():
	randomize()
	game_is_over = true
	$Player.is_active = false
	$PointFactory.is_active = false
	$EnemyFactory.is_active = false
	$EnemyFactory.kill_bosses()
	$PowerupFactory.is_active = false
	if(Settings.world["is_mission"] == false):
		$LevelController.stop()
	
	$HeadsUpDisplay/BombDisplay.visible = false
	$HeadsUpDisplay/HealthDisplay.visible = false

var active_states = [true, true, true]
var initial_settings
func _ready():
	if(Settings.shop["monocolor_color"] != null):
		modulate = Settings.shop["monocolor_color"]
		modulate = modulate.lightened(0.3)

	Global.world = self
	initial_settings = [Settings.world.duplicate(), Settings.factory.duplicate(), Settings.enemy.duplicate(), Settings.player.duplicate()]
	Settings.apply_sound_settings()
	save_active_states()
	start_new_game()
	
func save_active_states():
	var factories = [$PointFactory, $EnemyFactory, $PowerupFactory]
	var global_active_states = [Settings.factory["point_is_active"], Settings.factory["enemy_is_active"], Settings.factory["powerup_is_active"]]
	for i in range(len(factories)):
		if(factories[i].use_global_settings):
			active_states[i] = global_active_states[i]
		else:
			active_states[i] = factories[i].is_active
	
#	print("active_states, ", active_states)
var points_suffix = " s" if Settings.world["has_point_goal"] else ""
func start_new_game():
	Settings.world   = initial_settings[0].duplicate()
	Settings.factory = initial_settings[1].duplicate()
	Settings.enemy   = initial_settings[2].duplicate()
	Settings.player  = initial_settings[3].duplicate()
	if(get_node("LevelController")):
		$LevelController._ready()
	
	var high_score = HighScore.get_score(Settings.world["mission_title"])
	if(high_score != 0):
		$HeadsUpDisplay/HighScoreLabel.text = "High Score: " + Global.point_num_to_string( high_score) + points_suffix
	else:
		$HeadsUpDisplay/HighScoreLabel.text = "High Score: -"+ points_suffix
		
	$HeadsUpDisplay/CountdownLabel/CountdownAudio.pitch_scale = 1.0
	countdown_current_value = countdown_amount
	$HeadsUpDisplay/CountdownLabel.text = str(countdown_amount)
	$HeadsUpDisplay/CountdownLabel/CountdownAudio.play()
	$HeadsUpDisplay/CountdownLabel.visible = true
	$HeadsUpDisplay/CountdownLabel/CountdownTimer.start()
	
	game_is_over = false
	$Player.reset_settings()
	$Player.reset()
	$Player.is_active = true
	stop_factories()
	$HeadsUpDisplay.reset()
	$HeadsUpDisplay/BombDisplay.visible = Settings.get_setting_if_exists(Settings.player, "can_bomb", true)
	$HeadsUpDisplay/PointsLabel.visible = true
	$HeadsUpDisplay/HealthDisplay.visible = true
	$HeadsUpDisplay/TimeLabel.visible = true
	
	var health_sprite = Global.player_type_scenes[Settings.shop["player_type"]].instance()
	health_sprite.scale /= 2.5
	health_sprite.rotation_degrees -= 90
	$HeadsUpDisplay/HealthDisplay.add_child(health_sprite)


func stop_factories():
	$PointFactory.is_active = false
	$EnemyFactory.is_active = false
	$PowerupFactory.is_active = false
	
func start_factories():
	$EnemyFactory.reset()
	$PointFactory.reset()
	$PowerupFactory.reset()
	
func reset():
	start_new_game()

func _process(delta):
	if(countdown_is_over == false):
		if($HeadsUpDisplay/CountdownLabel.visible):
			$HeadsUpDisplay/CountdownLabel.modulate.a = move_toward($HeadsUpDisplay/CountdownLabel.modulate.a, 0, countdown_fade_speed * delta)
		
var countdown_sound_target_pitch = 1.7
func _on_CountdownTimer_timeout():
	countdown_is_over = false
	countdown_current_value -= 1
	$HeadsUpDisplay/CountdownLabel.modulate.a = 1.0

	if(countdown_current_value == 0):
		$HeadsUpDisplay/CountdownLabel.visible = false
		countdown_is_over = true
		start_factories()
	else:
		stop_factories()
		$HeadsUpDisplay/CountdownLabel/CountdownAudio.play()
		$HeadsUpDisplay/CountdownLabel/CountdownAudio.pitch_scale = move_toward($HeadsUpDisplay/CountdownLabel/CountdownAudio.pitch_scale, countdown_sound_target_pitch, (countdown_sound_target_pitch-1)/countdown_amount )
		$HeadsUpDisplay/CountdownLabel.text = str(countdown_current_value)
		$HeadsUpDisplay/CountdownLabel/CountdownTimer.start()
