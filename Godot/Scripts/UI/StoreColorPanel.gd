extends Node2D

export var title = ""
export var setting_name = ""
export var button_index = 0

export var is_selected = false
export var select_scale = 1.1
export var colors = [null, Color.white, Color.red, Color.blue, Color.yellow, Color.green, Color.hotpink, Color.cyan, Color.orange, Color.violet, Color.dodgerblue, Color.forestgreen, Color.beige, Color.firebrick, Color.lemonchiffon, Color.magenta, Color.bisque, Color.chocolate, Color.chartreuse]

var color_num = 0
var index = 0
var page
var spawned_particle_gens = []

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite.visible = false
	color_num = len(colors)
	$EquipmentName.visible = false
	
	$Light2D.color = modulate
	$Light2D2.color = modulate
	if(Settings.shop["monocolor_mode_unlocked"] != false):
		var c = Settings.shop["monocolor_color"]
		if(c != null):
			for i in range(len(colors)):
				if(colors[i] == c):
					index = i
					$Sprite2.visible = true
					modulate = c
					break
	
	update_labels()

func update():
	Settings.shop[setting_name] = index
	update_labels()

func update_labels():
	$Title.text = title
	Settings.shop[setting_name] = index

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
	
var equip_audio_fail_pitch = 1.9
var equip_audio_pitch = 1.0
func _on_ApplyLess_pressed():
	if(Settings.shop["monocolor_mode_unlocked"] == false):
		$EquipAudio.pitch_scale = equip_audio_fail_pitch
		$EquipAudio.play()
		return
		
	var init_index = index
	index = (index+1) % color_num
	$EquipAudio.pitch_scale = equip_audio_pitch
	$EquipAudio.play()
	
	var p = $DecreaseParticles.duplicate()
	p.emitting = true
	add_child(p)
	spawned_particle_gens.append(p)
	
	if(colors[index] != null):
		modulate = colors[index]
		$Sprite2.visible = true
		Settings.shop["monocolor_color"] = colors[index]
	else:
		modulate = Color.white
		$Sprite2.visible = false
		Settings.shop["monocolor_color"] = null

func _on_ApplyMore_pressed():
	if(Settings.shop["monocolor_mode_unlocked"] == false):
		$EquipAudio.pitch_scale = equip_audio_fail_pitch
		$EquipAudio.play()
		return
		
	var init_index = index
	index = (index-1+color_num) % color_num
	$EquipAudio.pitch_scale = equip_audio_pitch
	$EquipAudio.play()
	
	var p = $IncreaseParticles.duplicate()
	p.emitting = true
	add_child(p)
	spawned_particle_gens.append(p)
	
	if(colors[index] != null):
		modulate = colors[index]
		$Sprite2.visible = true
		Settings.shop["monocolor_color"] = colors[index]
	else:
		modulate = Color.white
		$Sprite2.visible = false
		Settings.shop["monocolor_color"] = null
		
func reset():
	index = 0
	update_labels()
	
func right():
	_on_ApplyMore_pressed()

func left():
	_on_ApplyLess_pressed()

func _process(delta):
	for i in range(len(spawned_particle_gens)):
		if(spawned_particle_gens[i].emitting == false):
			spawned_particle_gens[i].queue_free()
			spawned_particle_gens.remove(i)
			break
