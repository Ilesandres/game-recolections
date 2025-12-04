# Game.gd
extends Node3D

const PAUSE_MENU_SCENE = preload("res://src/UI/PauseMenu.tscn")
var pause_menu: CanvasLayer = null

@onready var player_container: Node3D = $PlayerContainer 


func _ready():
	pause_menu = PAUSE_MENU_SCENE.instantiate()
	add_child(pause_menu)
	pause_menu.set_process_priority(100)

	GlobalData.load_game()





func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		var menu_control = pause_menu.get_node("PauseMenu")
		
		if get_tree().paused:
			menu_control.unpause_game()
			print("continuando")
		else:
			menu_control.pause_game()

func _on_player_player_died():
	get_tree().paused = true
	
	print("JUEGO DETENIDO: Game Over.")
