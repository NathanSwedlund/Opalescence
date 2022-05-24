extends Node2D

export var title = "Title"
export var is_selected = false
var current_val

export var score_mult_unselected = 1.0
export var score_mult_selected = 1.2
export var selected_color = Color.cyan
export var unselected_color = Color.red
var score_mult = score_mult_selected

export var is_ui_selected = false
export var setting_name = ""

func _ready():
	$Title.text = title
	update_selected(is_selected)
	
func _process(delta):
	if(is_ui_selected):
		if(Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("ui_accept")):
			update_selected(!is_selected)
			$ChangeAudio.play()

func update_selected(_selected):
	is_selected = _selected
	modulate = selected_color if is_selected else unselected_color
	update_score_mult(is_selected)
	current_val = is_selected
	$Button.text = "o" if is_selected else "-" 
	
func update_score_mult(_selected):
#	emit_signal("update_score_mult")
	score_mult = score_mult_selected if _selected else score_mult_unselected
	get_parent().get_parent().update_global_score_mult()
	$ScoreMult.text = "X " + str(Global.round_float(score_mult, 2))

func _on_Button_pressed():
	update_selected(!is_selected)

	
