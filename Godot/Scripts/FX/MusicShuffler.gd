extends AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
export var song_paths = []
var songs = []
var current_song = 0
export var default_vol = 0.0
var index_in_playlist = 0
var song_order
func _ready():
	song_order = Array(range(len(song_paths)))
	randomize()
	song_order.shuffle()
	if(len(song_paths) == 0):
		return

	for s in song_paths:
		songs.append(load(s))

	current_song = randi()%len(songs)
	stream = songs[current_song]
	if(autoplay):
		_on_MusicShuffler_finished()


func _process(delta):
	if(Input.is_action_just_pressed("ui_v") or Input.is_action_just_pressed("controller_y")):
		_on_MusicShuffler_finished()

func _on_MusicShuffler_finished():
	index_in_playlist = (index_in_playlist + 1) % len(song_paths)
	current_song = song_order[index_in_playlist]
	stream = songs[current_song]
	play()
