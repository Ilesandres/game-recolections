extends Control

const GAME_SCENE_PATH = "res://scenes/game_scene.tscn" 
const MAIN_MENU_SCENE_PATH = "res://src/UI/MainMenu.tscn" 
var global_music_player=GlobalMusicPlayer.get_node("MusicPlayer")

signal pause_game_signal()
signal unpause_game_signal()
var game_root: Node

func _ready():
	hide()
	print("PauseMenu listo desde PauseMenu.gd")
	get_tree().paused = false
	#_unpause_music_global()


func _on_resume_button_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
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
	print("PAUSEMENU - Pausando juego- function")
	_unpause_music_global()
	emit_signal("pause_game_signal")
	print("PAUSEMENU - Señal pause_game_signal emitida")
	get_tree().paused = true
	show() 
	$PauseButtonContainer/ResumeButton.grab_focus()
	if get_node_or_null("../../Game"):
		get_node("../../Game")._unpause_music_global()

func unpause_game():
	_pause_music_global()
	get_tree().paused = false
	hide() 
	if get_node_or_null("../../Game"):
		get_node("../../Game")._pause_music_global()

func _pause_music_global():
	print("pausando musicca global desde pause menu")
	if is_instance_valid(global_music_player):
		global_music_player.set_stream_paused(true)
	else:
		print("error al pausar musica global desde pause menu")

func _unpause_music_global():
	print("reanudando musica global desde pause menu")
	if is_instance_valid(global_music_player):
		global_music_player.set_stream_paused(false)
	else:
		print("error al reanudar musica global desde pause menu")	
