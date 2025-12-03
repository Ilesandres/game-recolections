
extends Area3D

const OBSTACLE_VISUAL_SCENE = preload("res://src/Enemies/Cube.tscn")

func _ready():
	_add_visuals()
	
	body_entered.connect(_on_body_entered)

func _add_visuals():
	var visual_instance = OBSTACLE_VISUAL_SCENE.instantiate()
	
	add_child(visual_instance)
	
	#  Ajustar la posición vertical del modelo si es necesario 
	# visual_instance.position.y = 0.5 # Ajusta este valor si el pivote del modelo no está en el suelo

func _on_body_entered(body: Node3D):
	if body is CharacterBody3D and body.name == "Player": 
		
		if body.has_method("take_damage"):
			body.take_damage()
			
		queue_free()
