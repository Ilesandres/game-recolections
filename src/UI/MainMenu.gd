
extends Control


const GAME_SCENE_PATH = "res://scenes/game_scene.tscn"
const CHARACTER_SELECT_SCENE_PATH="res://src/UI/CharacterSelectMenu.tscn"

func _on_play_button_pressed():
	get_tree().change_scene_to_file(GAME_SCENE_PATH)

func _on_select_character_button_pressed():
	print("Navegando a la Selección de Personaje...")
	get_tree().change_scene_to_file(CHARACTER_SELECT_SCENE_PATH)

func _on_exit_button_pressed():
	get_tree().quit()
