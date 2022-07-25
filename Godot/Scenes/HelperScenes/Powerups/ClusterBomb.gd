extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var side_bomb_speed = 100

var side_bombs
var side_bomb_dirs = [Vector2.UP+Vector2.RIGHT, Vector2.UP+Vector2.LEFT, Vector2.DOWN+Vector2.RIGHT, Vector2.DOWN+Vector2.LEFT]

func _ready():
	side_bombs = [$Bomb1, $Bomb2, $Bomb3, $Bomb4]

func _process(delta):
	for i in range(4):
		if(is_instance_valid(side_bombs[i])):
			side_bombs[i].position += side_bomb_dirs[i]*delta*side_bomb_speed
	if(get_child_count() == 0):
		queue_free()
