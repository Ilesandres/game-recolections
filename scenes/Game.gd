# Game.gd
extends Node3D

const PAUSE_MENU_SCENE = preload("res://src/UI/PauseMenu.tscn")
const GAME_OVER_SCREEN_SCENE=preload("res://src/UI/GameOverMenu.tscn")
var pause_menu: CanvasLayer = null
var game_over_screen=null

@onready var player_container: Node3D = $PlayerContainer 


func _ready():
	pause_menu = PAUSE_MENU_SCENE.instantiate()
	game_over_screen= GAME_OVER_SCREEN_SCENE.instantiate()
	add_child(pause_menu)
	add_child(game_over_screen)
	pause_menu.set_process_priority(100)
	game_over_screen.set_process_priority(100)
	GlobalData.load_game()
	var level_spawner= $LevelSpawner
	level_spawner.current_level= GlobalData.current_level
	if level_spawner.has_method("setup_level"):
		level_spawner.setup_level(GlobalData.current_level)
	
	var player= $PlayerContainer.get_node("Player")
	var health_node= $HUD.get_node("health")
	if player and health_node:
		player.health_changed.connect(health_node.update_health)


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
	var game_over_control= game_over_screen
	GlobalData.save_game()
	if is_instance_valid(game_over_control):
		var hud=$HUD
		if hud:
			hud.hide()
		game_over_control.setup_game_over_screen(GlobalData.current_score, GlobalData.high_score)
	else:
		print("instancia no valida")

		print("hola 2.0")
	
	print("JUEGO DETENIDO: Game POver. desde Game")
