extends Control

const MAIN_MENU_SCENE_PATH="res://src/UI/MainMenu.tscn"
const GAME_SCENE_PATH="res://scenes/game_scene.tscn"

func _ready() -> void:
	pass 


func _process(delta: float) -> void:
	pass


func _on_level_1_pressed() :
	GlobalData.current_level=1
	GlobalData.save_game()


func _on_level_2_pressed() :
	GlobalData.current_level=2
	GlobalData.save_game()


func _on_level_3_pressed():
	GlobalData.current_level=3
	GlobalData.save_game()


func _on_level_4_pressed() :
	GlobalData.current_level=4
	GlobalData.save_game()


func _on_level_5_pressed() :
	GlobalData.current_level=5
	GlobalData.save_game()


func _on_button_pressed():
	if not GlobalData.current_level:
		GlobalData.current_level=1
		GlobalData.save_game()
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)


func _on_play_button_pressed():
	if not GlobalData.current_level:
		GlobalData.current_level=1
		GlobalData.save_game()
	get_tree().change_scene_to_file(GAME_SCENE_PATH)
	
