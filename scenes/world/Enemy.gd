
extends Area3D

var score_value: int = 10 

func take_hit():
	print("Enemigo destruido! Gana ", score_value, " puntos.")
	
	# 1. Lógica de Puntuación (Guardado Global se implementará después)
	# GlobalData.add_score(score_value)
	
	# 2. Destruir el enemigo
	queue_free()
