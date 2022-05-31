extends Label

export var fade_speed = 1.0
var should_fade_in  = false
var should_fade_out = false
export var automatically_fade_in = false
export var automatically_fade_out = false

# Called when the node enters the scene tree for the first time.
func _ready():
	modulate.a = 0.0
	if(automatically_fade_in):
		fade_in()
	if(automatically_fade_out):
		fade_out()

func _process(delta):
	if(should_fade_in):
		modulate.a = move_toward(modulate.a, 1.0, delta*fade_speed)
	if(should_fade_out):
		modulate.a = move_toward(modulate.a, 0.0, delta*fade_speed)

func fade_in():
	modulate.a = 0.0
	should_fade_in = true
	should_fade_out = false
	
func fade_out():
	modulate.a = 1.0
	should_fade_out = true
	should_fade_in = false
