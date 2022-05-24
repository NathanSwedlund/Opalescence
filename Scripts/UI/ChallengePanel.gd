extends Node2D

export var title = "Title"
export var starting_val = 1.0
var current_val = starting_val

export var max_val = 2.0
export var min_val = 0.0
export var min_color = Color.red
export var max_color = Color.cyan
export var step = 0.1
var score_mult = 1.0

export var score_mult_per_step = 0.06
export var setting_name = ""

export var is_ui_selected = false

func _process(delta):
	if(is_ui_selected):
		if(Input.is_action_just_pressed("ui_left")):
			_on_DecreaseButton_pressed()
		if(Input.is_action_just_pressed("ui_right")):
			_on_IncreaseButton_pressed()

func _ready():
	$Title.text = title
	update_current_val(current_val)

func _on_DecreaseButton_pressed():
	if(min_val < current_val - step):
		update_score_mult(score_mult * ( 1 - score_mult_per_step) )
		update_current_val(current_val - step)

func _on_IncreaseButton_pressed():
	if(max_val > current_val + step):
		update_score_mult(score_mult * ( 1 + score_mult_per_step) )
		update_current_val(current_val + step)

func update_current_val(val):
	current_val = val
	var ratio = (current_val-min_val)/(max_val-min_val)
	print(ratio)
	modulate = Color(move_toward(min_color.r, max_color.r, ratio), move_toward(min_color.g, max_color.g, ratio), move_toward(min_color.b, max_color.b, ratio))
	$Value.text = str(Global.round_float(current_val, 1))
	
func update_score_mult(_mult):
#	emit_signal("update_score_mult")
	score_mult = _mult
	get_parent().get_parent().update_global_score_mult()
	$ScoreMult.text = "X " + str(Global.round_float(score_mult, 2))
