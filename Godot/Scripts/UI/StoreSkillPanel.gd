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

var default_val = 0.0
var current_val = 0.0

var steps_already_taken = 0

var page

var spawned_particle_gens = []
# Called when the node enters the scene tree for the first time.
func _ready():
	$Light2D.color = modulate
	$Light2D2.color = modulate
	default_val = Settings.get_setting_if_exists(Settings.shop_default, setting_name, default_val)
	current_val = Settings.get_setting_if_exists(Settings.shop, setting_name, default_val)
	update_labels(true)

func try_buy():
	if(is_selected == false):
		return

	if(Settings.shop["tokens"] >= price and current_val + val_step <= max_val):
		Settings.shop["tokens"] -= price
		page.update_labels()

		current_val += val_step
		Settings.shop[setting_name] = current_val
		update_labels()
		$BuyAudio.play()
		
		var p = $IncreaseParticles.duplicate()
		p.emitting = true
		add_child(p)
		spawned_particle_gens.append(p)


func try_sell():
	if(is_selected == false ):
		return

	if(current_val > default_val):
		price = int(price/price_mult)
		Settings.shop["tokens"] += price

		page.update_labels()

		current_val -= val_step
		Settings.shop[setting_name] = current_val
		update_labels()
		$BuyAudio.play()
		$DecreaseParticles.emitting = true

		var p = $DecreaseParticles.duplicate()
		p.emitting = true
		add_child(p)
		spawned_particle_gens.append(p)

func update():
	Settings.shop[setting_name] = current_val
	update_labels()

func update_labels(init=false):
	$Title.text = title

	steps_already_taken = (current_val - default_val)/val_step
	price = int(default_price * pow(price_mult, steps_already_taken))

	$Current.text = "Current: " + str(current_val)
	var next = current_val + val_step
	var last = current_val - val_step
	if(last < default_val):
		$Last.text = "Last: _"
		$Price.text = "Price: "+str(Global.point_num_to_string(price, ["b", "m", "k"]))+"tkns"
		$Next.text = "Next: " + str(next)
		$Light2D2.color = modulate
		$ApplyLess.visible = false
	elif(next > max_val):
		$Last.text = "Last: " + str(last)
		$Price.text = "MAXED"
		$Next.text = "Next: _"
		if(init == false):
			$MaxedAudio.play()
			$MaxedExplosion.restart()
			$MaxedExplosion.emitting = true
		$Light2D2.color = modulate
		$ApplyMore.visible = false
	else:
		$Last.text = "Last: " + str(last)
		$Price.text = "Price: "+str(Global.point_num_to_string(price, ["b", "m", "k"]))+"tkns"
		$Next.text = "Next: " + str(next)
		$Light2D2.color = modulate
		$ApplyLess.modulate = modulate
		$ApplyLess.visible = true
		$ApplyMore.modulate = modulate
		$ApplyMore.visible = true



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

func _on_ApplyLess_pressed():
	try_sell()

func _on_ApplyMore_pressed():
	try_buy()

func reset():
	current_val = default_val
	update_labels()

func right():
	try_buy()

func left():
	try_sell()
	
func _process(delta):
	for i in range(len(spawned_particle_gens)):
		if(spawned_particle_gens[i].emitting == false):
			spawned_particle_gens[i].queue_free()
			spawned_particle_gens.remove(i)
			break
