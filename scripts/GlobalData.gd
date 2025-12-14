
extends Node

var current_level: int= 1
var current_xp: int =0
var xp_to_next_level: int =100
var current_score: int = 0
var total_global_trash: int = 0 
var high_score: int = 0

const SAVE_PATH = "user://game_save.dat"
var selected_character_scene_path: String="res://scenes/characters/character_k_2.tscn"
var selected_weapon_scene_path: String = "res://src/weapons/blaster_a.tscn"
var selected_bullet_scene_path: String = "res://src/weapons/bullets/bullet_foam_tip_thick.tscn"
var damage_weapon_multiplier: float = 1.0
var weapon_cooldown:bool = true
var character_health:int=3
var weapon_sound_shoot_path:String="res://assets/audio/weapons/shoots/shoot-arma-blaster-a.mp3";
var character_power_1:String="ShootOne";
var character_power_1_description:String="Disparo unico";
var character_power_2:String="nomalSpeed";
var character_power_2_description:String="Velocidad normal";
var character_power_3:String="";
var character_power_3_description:String="";

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
		"xp_to_next_level": xp_to_next_level,
		"selected_character_scene_path": selected_character_scene_path,
		"selected_weapon_scene_path": selected_weapon_scene_path,
		"selected_bullet_scene_path": selected_bullet_scene_path,
		"damage_weapon_multiplier": damage_weapon_multiplier,
		"weapon_cooldown": weapon_cooldown,
		"character_health": character_health,
		"weapon_sound_shoot_path": weapon_sound_shoot_path,
		"character_power_1": character_power_1,
		"character_power_1_description": character_power_1_description,
		"character_power_2": character_power_2,
		"character_power_2_description": character_power_2_description,
		"character_power_3": character_power_3,
		"character_power_3_description": character_power_3_description
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
				selected_character_scene_path = data.get("selected_character_scene_path", "res://scenes/characters/character_k_2.tscn")
				selected_weapon_scene_path = data.get("selected_weapon_scene_path", "res://src/weapons/blaster_a.tscn")
				selected_bullet_scene_path = data.get("selected_bullet_scene_path", "res://src/weapons/bullets/bullet_foam_tip_thick.tscn")
				damage_weapon_multiplier = data.get("damage_weapon_multiplier", 1.0)
				weapon_cooldown = data.get("weapon_cooldown", true)
				character_health = data.get("character_health", 3)
				weapon_sound_shoot_path = data.get("weapon_sound_shoot_path", "res://assets/audio/weapons/shoots/shoot-arma-blaster-a.mp3")
				character_power_1 = data.get("character_power_1", "ShootOne")
				character_power_1_description = data.get("character_power_1_description", "Disparo unico")
				character_power_2 = data.get("character_power_2", "nomalSpeed")
				character_power_2_description = data.get("character_power_2_description", "Velocidad normal")
				character_power_3 = data.get("character_power_3", "")
				character_power_3_description = data.get("character_power_3_description", "")
			else:
				print("Error al analizar el archivo de guardado.")
			file.close()

	current_score = 0 
