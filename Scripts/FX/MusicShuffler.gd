extends AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
export var song_paths = []
var songs = []
var current_song = 0
export var default_vol = 0.0

func _ready():
	if(len(song_paths) == 0):
		return
		
	for s in song_paths:
		songs.append(load(s))
		
	current_song = randi()%len(songs)
	stream = songs[current_song]
	if(autoplay):
		play()

func _on_MusicShuffler_finished():
	var new_song = randi()%len(songs)
	while(current_song == new_song):
		new_song = randi()%len(songs)
	
	current_song = new_song
	stream = songs[current_song]
	play()
