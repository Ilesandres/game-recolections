
extends Control

const GAME_SCENE_PATH = "res://scenes/game_scene.tscn" 
const MAIN_SCENE_PATH= "res://src/UI/MainMenu.tscn"

const CHARACTER_PATHS = {
	"K": "res://scenes/characters/character_k_2.tscn",
	"O": "res://scenes/characters/character_o_2.tscn",
	"P": "res://scenes/characters/character_p_2.tscn",
	"R": "res://scenes/characters/character_r_2.tscn",
}
@onready var character_disply_3d=$DisplayContainer/CharacterViewport/CharacterDisplay3D

var current_selection_key: String = "K" 


func select_character(key: String):
	current_selection_key = key
	print("Seleccionado personaje: " + key)
	
	GlobalData.selected_character_scene_path = CHARACTER_PATHS[key]
	if is_instance_valid(character_disply_3d):
		character_disply_3d.load_selected_character()
	else:
		print(" error al cargar el personaje seleccionado")
	


func _on_play_button_pressed():
	if not GlobalData.selected_character_scene_path:
		select_character("K") 
		
	print("Iniciando juego con: " + GlobalData.selected_character_scene_path)
	
	get_tree().change_scene_to_file(GAME_SCENE_PATH)


func _on_select_character_r_pressed() :
	select_character("R")


func _on_select_character_k_pressed() :
	print("seleccionando k"+GlobalData.selected_character_scene_path)
	select_character("K")


func _on_select_character_o_pressed() :
	select_character("O")
	

func _on_select_character_p_pressed() :
	select_character("P")


func _on_back_button_pressed():
	if not GlobalData.selected_character_scene_path:
		select_character("K") 
	print("Regresando al menú principal con: " + GlobalData.selected_character_scene_path)
	get_tree().change_scene_to_file(MAIN_SCENE_PATH)
	
