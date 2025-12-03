
extends Area3D

var score_value: int = 10 

func take_hit():
	print("Enemigo destruido! Gana ", score_value, " puntos.")
	
	GlobalData.add_score(score_value)
	
	queue_free()
