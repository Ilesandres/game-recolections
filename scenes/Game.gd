
extends Node3D

func _on_player_player_died():
	get_tree().paused = true
	
	print("JUEGO DETENIDO: Game Over.")
