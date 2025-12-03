extends Area3D

const OBSTACLE_VISUAL_SCENE = preload("res://src/Enemies/Cube.tscn")
const OBSTACLE_VISUAL_SCENE_2 = preload("res://src/Enemies/CarRed.tscn")

func _ready():
	randomize() 
	
	_add_visuals_random()
	
	body_entered.connect(_on_body_entered)

func _add_visuals_random():
	var random_number = randi_range(1, 2)
	var visual_scene
	
	if random_number == 1:
		visual_scene = OBSTACLE_VISUAL_SCENE
	elif random_number == 2:
		visual_scene = OBSTACLE_VISUAL_SCENE_2
	
	var visual_instance = visual_scene.instantiate()
	add_child(visual_instance)
	
	# Comentario original para ajustar la posición vertical:
	# visual_instance.position.y = 0.5 # Ajusta este valor si el pivote del modelo no está en el suelo

func _on_body_entered(body: Node3D):
	if body is CharacterBody3D and body.name == "Player":
		
		if body.has_method("take_damage"):
			body.take_damage()
			
		queue_free()
