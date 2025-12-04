
extends Node

var current_level: int= 1
var current_xp: int =0
var xp_to_next_level: int =100
var current_score: int = 0
var total_global_trash: int = 0 
var high_score: int = 0

const SAVE_PATH = "user://game_save.dat"
var selected_character_scene_path: String="res://scenes/characters/character_k_2.tscn"

func add_score(amount: int):
	current_score += amount
	total_global_trash += amount

func save_game():
	high_score = maxi(current_score, high_score)
	
	var save_dict = {
		"global_trash": total_global_trash,
		"high_score": high_score,
		"current_level": current_level,
		"current_xp": current_xp,
		"xp_to_next_level": xp_to_next_level
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_line(JSON.stringify(save_dict))
		file.close()
	
func load_game():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var json_string = file.get_line()
			var data = JSON.parse_string(json_string)
			if typeof(data) == TYPE_DICTIONARY:
				total_global_trash = data.get("global_trash", 0)
				high_score = data.get("high_score", 0)
				current_level = data.get("current_level", 1)
				current_xp = data.get("current_xp", 0)
				xp_to_next_level = data.get("xp_to_next_level", 100)
			file.close()

	current_score = 0 
