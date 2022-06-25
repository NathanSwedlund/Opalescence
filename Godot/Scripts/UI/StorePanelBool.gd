extends Node2D

export var title = ""
export var setting_name = ""
export var price = 100

export var button_index = 0

export var is_selected = false
export var select_scale = 1.1

var has_purchased
var page

# Called when the node enters the scene tree for the first time.
func _ready():
	$Light2D.color = modulate
	$Light2D2.color = modulate
	has_purchased = Settings.get_setting_if_exists(Settings.shop, setting_name, false)
	update_labels()

func _on_BuyButton_pressed():
	try_buy()
	
func try_buy():
	if(is_selected == false):
		return
		
	if(Settings.shop["points"] >= price and !has_purchased):
		has_purchased = true
		Settings.shop["points"] -= price
		page.update_point_label()

		Settings.shop[setting_name] = true
		Settings.save()
		update_labels()
		$BuyAudio.play()
		
func update_labels():
	$Title.text = title
	if(!has_purchased):
		$Price.text = "Price: "+str(Global.point_num_to_string(price, ["b", "m", "k"]))
		$Light2D2.color = modulate
		$BuyButton.modulate = modulate
	else:
		$Price.text = ""
		$Light2D2.color = Color.black
		$BuyButton.modulate = Color.gray
		$BuyButton.text = "PURCHASED"
		
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

func reset():
	Settings.shop[setting_name] = false
	has_purchased = false
	update_labels()
	
func set_page(_page):
	page = _page
