extends Node

var high_scores = {}
var high_scores_def = {}
var save_path = "user://highScores.dat"

func _ready():
	load_high_scores()
	
func save_high_scores():
	Global.save_var(save_path, high_scores)
	
func load_high_scores():
	var loaded = Global.load_var(save_path)
	if(loaded == null):
		high_scores = high_scores_def
	else:
		high_scores = loaded
			
func record_score(score, score_title, more_is_better=true):
	var old_score = get_score(score_title)
	if(old_score == 0 or (score > old_score and more_is_better) or (score < old_score and !more_is_better) ):
		high_scores[score_title] = score
		save_high_scores()

func get_score(score_title):
	print(high_scores)
	if( (score_title in high_scores.keys() ) == false):
		print("\n Loading score, 0", score_title)
		return 0
	if(high_scores[score_title] == null):
		print("\n Loading score, 0", score_title)
		return 0
	
	print("\n Loading score ", score_title, high_scores[score_title])
	return high_scores[score_title]
