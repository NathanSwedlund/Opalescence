extends Node

var player = null
var target_frame_rate = 60.0
var points_this_round = 0

var main_menu_has_faded = false
var return_scene = "res://Scenes/MainScenes/MainMenu.tscn"

var ui_states = {}

func save_var(path, _var):
	print("Saving ", _var, " at ", path)
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_var(_var)
	file.close()

func load_var(path):
	var file = File.new()
	file.open(path, file.READ)
	var settings_from_file = file.get_var()
	file.close()
	return settings_from_file
	
func round_float(_float, decimal_num):
	return int( _float * pow(10, decimal_num) )/(pow(10, decimal_num))
	

var suffix_nums = [1000000000.0, 1000000.0, 1000.0]
func point_num_to_string(point_num, suffixes):
	for i in range(len(suffixes)):
		if(abs(point_num) > suffix_nums[i]):
			return str(round_float( point_num/suffix_nums[i], 3)) + suffixes[i] 
	return str(point_num)
