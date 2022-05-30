extends Node2D

export var point_multiplier = 1.0
export var game_is_over = false

var songs_scenes = ["res://Resources/Audio/Music/Jagged Skies.mp3", "res://Resources/Audio/Music/Knight City.mp3", "res://Resources/Audio/Music/OPALESCENCE.wav", "res://Resources/Audio/Music/The Wayward Mines.mp3"]
var songs = []
var current_song = 0

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
	$PowerupFactory.is_active = false

	$HeadsUpDisplay/BombDisplay.visible = false
#	$HeadsUpDisplay/PointsLabel.visible = false
	$HeadsUpDisplay/HealthDisplay.visible = false
#	$HeadsUpDisplay/TimeLabel.visible = false
	
func _ready():
	Settings.apply_sound_settings()
	for s in songs_scenes:
		songs.append(load(s))
		
	current_song = randi()%len(songs_scenes)
	$AudioStreamPlayer2D.stream = songs[current_song]
	$AudioStreamPlayer2D.play()
	start_new_game()

func start_new_game():
	$HeadsUpDisplay/HighScoreLabel.text = "High Score: " + Global.point_num_to_string( HighScore.get_score(Settings.world["mission_title"]), ["b", "m"] )
	$HeadsUpDisplay/CountdownLabel/CountdownAudio.pitch_scale = 1.0
	countdown_current_value = countdown_amount
	$HeadsUpDisplay/CountdownLabel.text = str(countdown_amount)
	$HeadsUpDisplay/CountdownLabel/CountdownAudio.play()
	$HeadsUpDisplay/CountdownLabel.visible = true
	$HeadsUpDisplay/CountdownLabel/CountdownTimer.start()
	
	game_is_over = false
	$Player.reset()
	$Player.is_active = true
	stop_factories()
	$HeadsUpDisplay.reset()
	$HeadsUpDisplay/BombDisplay.visible = Settings.get_setting_if_exists(Settings.player, "can_bomb", true)
	$HeadsUpDisplay/PointsLabel.visible = true
	$HeadsUpDisplay/HealthDisplay.visible = true
	$HeadsUpDisplay/TimeLabel.visible = true
	
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

func _on_AudioStreamPlayer2D_finished():
	current_song = randi()%len(songs_scenes)
	$AudioStreamPlayer2D.stream = songs[current_song]
	$AudioStreamPlayer2D.play()

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
