
extends Control


const GAME_SCENE_PATH = "res://scenes/game_scene.tscn"
const CHARACTER_SELECT_SCENE_PATH="res://src/UI/CharacterSelectMenu.tscn"
const WEAPON_SELECT_SCENE_PATH="res://src/UI/WeaponMain.tscn"
var global_music_player=GlobalMusicPlayer.get_node("MusicPlayer")

func _ready():
	_unpause_music_global()

func _on_play_button_pressed():
	get_tree().change_scene_to_file(GAME_SCENE_PATH)

func _on_select_character_button_pressed():
	print("Navegando a la Selección de Personaje...")
	get_tree().change_scene_to_file(CHARACTER_SELECT_SCENE_PATH)

func _on_exit_button_pressed():
	get_tree().quit()


func _on_level_button_pressed() :
	get_tree().change_scene_to_file("res://src/UI/LevelMenu.tscn")


func _on_select_weapon_pressed() :
	get_tree().change_scene_to_file(WEAPON_SELECT_SCENE_PATH)

func _pause_music_global():
	print("pausando musicca global desde main menu")
	if is_instance_valid(global_music_player):
		global_music_player.set_stream_paused(true)
	else:
		print("error al pausar musica global desde main menu")

func _unpause_music_global():
	print("reanudando musica global desde main menu")
	if is_instance_valid(global_music_player):
		global_music_player.set_stream_paused(false)
	else:
		print("error al reanudar musica global desde main menu")