extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	$HighScore.text = "High Score: " + str(HighScore.get_score("challenge"))
#	for c in $ChallengePanels.get_children():
#		c.connect("update_score_mult", self, "update_global_score_mult")
#		print(c.name)

var score_mult = 1.0
func update_global_score_mult():
	print("update_global_score_mult")
	score_mult = 1.0
	for c in $ChallengePanels.get_children():
		score_mult *= c.score_mult
		
	$ScoreMult.text = "Score Multiplier: X" + str(score_mult)

func _on_ReadyButton_pressed():
	for c in $ChallengePanels.get_children():
		for d in [Settings.world, Settings.factory, Settings.enemy, Settings.player]:
			for key in d.keys():
				if(c.setting_name == key):
					print("Setting ", key, " to ", c.current_val)
					d[key] = c.current_val

	Settings.world["points_scale"] = score_mult
	get_tree().change_scene("res://Scenes/MainScenes/World.tscn")
