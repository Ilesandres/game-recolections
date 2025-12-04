# Game.gd
extends Node3D

const PAUSE_MENU_SCENE = preload("res://src/UI/PauseMenu.tscn")
var pause_menu: CanvasLayer = null

@onready var player_container: Node3D = $PlayerContainer 


func _ready():
	var player_node: Node3D = _instantiate_selected_player() 
	
	pause_menu = PAUSE_MENU_SCENE.instantiate()
	add_child(pause_menu)
	pause_menu.set_process_priority(100)
	
	GlobalData.load_game()
	
	if is_instance_valid(player_node):
		if player_node.has_method("_on_player_player_died"):
			player_node.player_died.connect(_on_player_player_died)


func _instantiate_selected_player() -> Node3D: 
	var player_path = GlobalData.selected_character_scene_path
	
	if player_path.is_empty():
		print("ADVERTENCIA: Ruta de personaje vacía. Usando default.")
		player_path = "res://scenes/characters/character_k_2.tscn"
		
	var PlayerScene = load(player_path)
	var new_player = PlayerScene.instantiate()
	
	player_container.add_child(new_player)
	
	new_player.name = "Player"
	
	return new_player


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
