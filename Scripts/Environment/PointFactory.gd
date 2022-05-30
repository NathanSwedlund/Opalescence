extends Node2D

var point_scene = load("res://Scenes/HelperScenes/Point.tscn")

export var use_global_settings = true

export var left_bound = 0
export var right_bound = 0
export var up_bound = 0
export var down_bound = 0
export var time_min = 0.8
export var time_max = 4.0
export var is_active = true


var color_count

onready var player = get_parent().find_node("Player")
# Called when the node enters the scene tree for the first time.
func _ready():
	if(use_global_settings):
		left_bound = Settings.get_setting_if_exists(Settings.world, "left_bound", left_bound)
		right_bound = Settings.get_setting_if_exists(Settings.world, "right_bound", right_bound)
		up_bound = Settings.get_setting_if_exists(Settings.world, "up_bound", up_bound)
		down_bound = Settings.get_setting_if_exists(Settings.world, "down_bound", down_bound)

		time_min = Settings.get_setting_if_exists(Settings.factory, "point_time_min", time_min)
		time_max = Settings.get_setting_if_exists(Settings.factory, "point_time_max", time_max)

	color_count = len(Settings.get_setting_if_exists(Settings.saved_settings, "colors", [Color.white]))
	randomize()


func spawn_point():
	var point = point_scene.instance()
	var position_x = rand_range(left_bound, right_bound)
	var position_y = rand_range(up_bound, down_bound)

	point.position = Vector2(position_x, position_y)
	point.player = player
	var c = Settings.get_setting_if_exists(Settings.saved_settings, "colors", [Color.white])[randi()%color_count]
	point.modulate = c
	$Points.add_child(point)

func reset():
	is_active = Settings.get_setting_if_exists(Settings.factory, "point_is_active", is_active)
	_ready()

func kill_all():
	for c in $Points.get_children():
		c.queue_free()

func _on_Timer_timeout():
	if(is_active):
		spawn_point()

	var time_until_next = rand_range(time_min, time_max)
	$Timer.wait_time = time_until_next
