extends Node2D

export var point_multiplier = 1.0
export var game_is_over = false


var songs_scenes = [	"res://Resources/Audio/Music/Jagged Skies.mp3", "res://Resources/Audio/Music/Knight City.mp3", "res://Resources/Audio/Music/OPALESCENCE.wav", "res://Resources/Audio/Music/The Wayward Mines.mp3"]
var songs = []
var current_song = 0

func game_over():
	randomize()
	game_is_over = true
	$Player.is_active = false
	$PointFactory.is_active = false
	$EnemyFactory.is_active = false
	$PowerupFactory.is_active = false

	$HeadsUpDisplay/BombDisplay.visible = false
	$HeadsUpDisplay/PointsLabel.visible = false
	$HeadsUpDisplay/HealthDisplay.visible = false
	$HeadsUpDisplay/TimeLabel.visible = false
	
	
func _ready():
	for s in songs_scenes:
		songs.append(load(s))
		
	current_song = randi()%len(songs_scenes)
	$AudioStreamPlayer2D.stream = songs[current_song]
	$AudioStreamPlayer2D.play()
	
#	print(Settings.world)
	print(Settings.factory)
#	print(Settings.enemy)
#	print(Settings.player)

func start_new_game():
	game_is_over = false
	$Player.reset()
	$EnemyFactory.reset()
	$PointFactory.reset()
	$PowerupFactory.reset()
	$HeadsUpDisplay.reset()
	$HeadsUpDisplay/BombDisplay.visible = true
	$HeadsUpDisplay/PointsLabel.visible = true
	$HeadsUpDisplay/HealthDisplay.visible = true
	$HeadsUpDisplay/TimeLabel.visible = true
	reset()

func reset():
	$Player.is_active = true
	$PointFactory.reset()
	$EnemyFactory.reset()
	$PowerupFactory.reset()



func _on_AudioStreamPlayer2D_finished():
	current_song = randi()%len(songs_scenes)
	$AudioStreamPlayer2D.stream = songs[current_song]
	$AudioStreamPlayer2D.play()
