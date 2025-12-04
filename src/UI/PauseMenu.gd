extends Control

const GAME_SCENE_PATH = "res://scenes/game_scene.tscn" 
const MAIN_MENU_SCENE_PATH = "res://src/UI/MainMenu.tscn" 

var game_root: Node

func _ready():
	hide()
	get_tree().paused = false


func _on_resume_button_pressed():
	print("continuando partida")
	unpause_game()

func _on_restart_button_pressed():
	print("hola mundo pause menu")
	unpause_game()
	get_tree().reload_current_scene()
	GlobalData.current_score = 0

func _on_main_menu_button_pressed():
	print("hola pause menu")
	unpause_game()
	GlobalData.save_game()
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)


func pause_game():
	
	get_tree().paused = true
	show() 
	$PauseButtonContainer/ResumeButton.grab_focus()

func unpause_game():
	get_tree().paused = false
	hide() 
