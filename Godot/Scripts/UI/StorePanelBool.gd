extends Node2D

export var title = ""
export var setting_name = ""
export var price = 100

export var button_index = 0

export var is_selected = false
export var select_scale = 1.1

var has_purchased
var page
export var base_color = Color.white
export var purchased_color = Color()
export var purchase_juice_scale = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	has_purchased = Settings.get_setting_if_exists(Settings.shop, setting_name, false)
	$Frames/UnpurchasedFrame.visible = !has_purchased
	modulate = base_color if has_purchased == false else purchased_color
	
	$Light2D.color = modulate
	$Light2D2.color = modulate
	$BuyExplosionParticles.scale *= purchase_juice_scale
	$BuyExplosionParticles.amount *= (1+purchase_juice_scale)/2
	$BuyExplosionParticles2.amount *= (1+purchase_juice_scale)/2
	$BuyExplosionParticles3.amount *= (1+purchase_juice_scale)/2
	$BuyExplosionParticles4.amount *= (1+purchase_juice_scale)/2

	$BuyImplosionParticles.scale *= purchase_juice_scale
	$BuyImplosionParticles.amount *= (1+purchase_juice_scale)/2
	
	$BuyAudioRiser.pitch_scale *= 2/(1+purchase_juice_scale)
	$BuyAudio2.pitch_scale *= 2/(1+purchase_juice_scale)
	$BuyAudio3.pitch_scale *= 2/(1+purchase_juice_scale)
	$BuyParticlesTimer.wait_time *= purchase_juice_scale
	update_labels()

func _on_BuyButton_pressed():
	try_buy()
	
func try_buy():
	if(is_selected == false):
		return
		
	if(Settings.shop["points"] >= price and !has_purchased):
		has_purchased = true
		page.start_point_deduction_event(price, purchase_juice_scale)

		Settings.shop[setting_name] = true
		Settings.save()	
		$BuyImplosionParticles.emitting = true
		$BuyAudioRiser.play()
		$BuyParticlesTimer.start()
		$BuyExplosionParticles2.emitting = true
		$BuyExplosionParticles3.emitting = true
		$BuyExplosionParticles4.emitting = true
		$Frames/UnpurchasedFrame.visible = false
		Global.shakes["laser"].start(15*purchase_juice_scale, 1.6*purchase_juice_scale, 80, 1)

		
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


func _on_BuyParticlesTimer_timeout():
	$BuyAudioRiser.stop()
	$BuyAudio.play()
	$BuyAudio2.play()
	$BuyAudio3.play()
	$BuyExplosionParticles.emitting = true
	$BuyImplosionParticles.emitting = false
	$BuyImplosionParticles.visible = false
	modulate = purchased_color
	$Frames/UnpurchasedFrame2.visible = false
	$Light2D.color = modulate
	$Light2D2.color = modulate	
	update_labels()
	Global.shakes["bomb"].start(100*purchase_juice_scale, 0.4*purchase_juice_scale, 80, 1)
	Global.shakes["laser"].start(7*purchase_juice_scale, 1.6*purchase_juice_scale, 80, 1)
	page.change_color(modulate)
