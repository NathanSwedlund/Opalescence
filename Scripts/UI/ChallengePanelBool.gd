extends Node2D

export var title = "Title"
export var is_selected = false
var current_val

export var score_mult_unselected = 1.0
export var score_mult_selected = 1.2
var score_mult = score_mult_selected

export var setting_name = ""

func _ready():
	$Title.text = title
	update_selected(is_selected)

func update_selected(_selected):
	is_selected = _selected
	update_score_mult(is_selected)
	current_val = is_selected
	$Button.text = "(-)" if is_selected else "()" 
	
func update_score_mult(_selected):
#	emit_signal("update_score_mult")
	score_mult = score_mult_selected if _selected else score_mult_unselected
	get_parent().get_parent().update_global_score_mult()
	$ScoreMult.text = "X " + str(Global.round_float(score_mult, 2))

func _on_Button_pressed():
	update_selected(!is_selected)

	
