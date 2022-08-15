extends Node2D

var players
var x_sep = 350
var y_loc = 400
var max_x = 1500
func _ready():
#	players = [$PlayerType2, $PlayerType1, $PlayerType3]
#
#	var player_num = len(players)
#	for i in range(player_num):
#		players[i].position.x = lerp(0, max_x, (i+1.0)/float(player_num+2))
#		players[i].position.y = y_loc
#
#		players[i].rotation_degrees = -45

	$VersionLabel.text = Global.version
