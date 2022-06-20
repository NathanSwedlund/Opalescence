extends Node2D

export var title = ""
export var setting_name = ""
export var button_index = 0

export var is_selected = false
export var select_scale = 1.1
export var images = []
export var names = []
export var locked_settings = []

var image_num = 0
var index = 0
var page

# Called when the node enters the scene tree for the first time.
func _ready():
	image_num = len(images)
	
	for i in range(image_num): # loading images
		images[i] = load(images[i])
		
	$Light2D.color = modulate
	$Light2D2.color = modulate
	index = int(Settings.get_setting_if_exists(Settings.shop, setting_name, index))
	update_labels()
		
func update():
	Settings.shop[setting_name] = index
	update_labels()
		
func update_labels():
	$Title.text = title
	$Sprite.texture = images[index]
	$EquipmentName.text = names[index]
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

func select_image(_index):
	index = _index
	Settings.player[setting_name] = index
	update_labels()
	
var equip_audio_fail_pitch = 1.9
var equip_audio_pitch = 1.0

func _on_ApplyLess_pressed():
	var init_index = index
	
	index = (index+1) % image_num
	while(Settings.shop[locked_settings[index]] != true):
		index = (index+1) % image_num
		
	if(init_index == index): # no other equipment to swap to
		$EquipAudio.pitch_scale = equip_audio_fail_pitch
	else:
		$EquipAudio.pitch_scale = equip_audio_pitch
		
	$EquipAudio.play()
	select_image( index )

func _on_ApplyMore_pressed():
	var init_index = index
	
	index = (index-1+image_num) % image_num
	while(Settings.shop[locked_settings[index]] != true):
		index = (index-1+image_num) % image_num
		
	if(init_index == index): # no other equipment to swap to
		$EquipAudio.pitch_scale = equip_audio_fail_pitch
	else:
		$EquipAudio.pitch_scale = equip_audio_pitch
		
	$EquipAudio.play()
	select_image( index )
	
func reset():
	index = 0
	update_labels()
	
func right():
	_on_ApplyMore_pressed()

func left():
	_on_ApplyLess_pressed()
