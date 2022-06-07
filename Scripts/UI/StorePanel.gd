extends Node2D

export var title = ""
export var setting_name = ""

export var default_price = 1000.0
var price

export var price_mult = 2.0

export var val_step = 0.1
export var max_val = 10.0 
export var button_index = 0

export var is_selected = false
export var select_scale = 1.1

export var default_val = 0
var current_val = 0

var steps_already_taken = 0

var page

# Called when the node enters the scene tree for the first time.
func _ready():
	$Light2D.color = modulate
	$Light2D2.color = modulate
	
	current_val = Settings.get_setting_if_exists(Settings.shop, setting_name, default_val)
	update_labels()

func _on_BuyButton_pressed():
	try_buy()
	
func try_buy():
	if(is_selected == false):
		return
		
	if(Settings.shop["points"] >= price and current_val + val_step <= max_val):
		Settings.shop["points"] -= price
		page.update_point_label()

		current_val += val_step 
		Settings.shop[setting_name] = current_val
		Settings.save()
		update_labels()
		$BuyAudio.play()
		
func update_labels():
	$Title.text = title
	
	steps_already_taken = (current_val - default_val)/val_step
	price = default_price * pow(price_mult, steps_already_taken)
	$Price.text = "Price: "+str(Global.point_num_to_string(price, ["k", "m", "b"]))
	
	$Current.text = "Current: " + str(current_val)
	var next = current_val + val_step
	if(next <= max_val):
		$Next.text = "Next: " + str(current_val + val_step)
	else:
		$Next.text = "Next: _"
		$Light2D2.color = Color.black
		$BuyButton.modulate = Color.gray
		
func select():
	$Particles2D.visible = true
	$Light2D.visible = true
	$Light2D2.visible = true
	is_selected = true
	scale *= select_scale

func deselect():
	$Particles2D.visible = false
	$Light2D.visible = false
	$Light2D2.visible = false
	is_selected = false
	scale /= select_scale
