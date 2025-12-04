extends Node3D

const CHUNK_SCENE = preload("res://scenes/world/chunk_template.tscn")
const OBSTACLE_SCENE = preload("res://scenes/world/Obstacle.tscn") 
const ENEMY_SCENE = preload("res://scenes/world/Enemy.tscn")
const CHUNK_LENGTH = 30.0 

@onready var player: CharacterBody3D = get_parent().find_child("PlayerContainer", true).get_node("Player") 


var last_chunk: Node3D = null     
var active_chunks: Array[Node3D] = [] 
var next_spawn_position: Vector3 = Vector3.ZERO

# Configuración de dificultad por nivel
var spawn_speed = 1.0
var object_spawn_chance = 0.33

func configure_for_level(level: int):
	match level:
		1:
			spawn_speed = 1.0
			object_spawn_chance = 0.2
		2:
			spawn_speed = 1.2
			object_spawn_chance = 0.3
		3:
			spawn_speed = 1.5
			object_spawn_chance = 0.4
		4:
			spawn_speed = 1.8
			object_spawn_chance = 0.5
		5:
			spawn_speed = 2.0
			object_spawn_chance = 0.6


func _ready():
	configure_for_level(GlobalData.current_level)
	_spawn_chunk(next_spawn_position)
	_spawn_chunk(next_spawn_position)
	_spawn_chunk(next_spawn_position)
	
func _process(_delta: float): 
	if not is_instance_valid(player): 
		return
		
	if last_chunk and player.global_position.z < last_chunk.global_position.z - 15.0:
		_spawn_chunk(next_spawn_position)

	if active_chunks.size() > 0:
		var oldest_chunk = active_chunks[0]
		
		if is_instance_valid(oldest_chunk) and oldest_chunk.has_node("DespawnPoint"):
			
			var despawn_point_z = oldest_chunk.get_node("DespawnPoint").global_position.z
			
			if player.global_position.z < despawn_point_z:
				_despawn_chunk(oldest_chunk)
				
				
func _spawn_chunk(target_position: Vector3): 
	var new_chunk = CHUNK_SCENE.instantiate()
	add_child(new_chunk)
	
	new_chunk.global_position = target_position 
	
	
	var obstacle_points = new_chunk.get_node("ObstaclePoints").get_children()
	

	for point in obstacle_points:
		if randf() < object_spawn_chance:
			var item_roll = randf()
			var item_instance = null
			if item_roll < 0.5:
				item_instance = OBSTACLE_SCENE.instantiate()
			else:
				item_instance = ENEMY_SCENE.instantiate()
			if item_instance:
				item_instance.global_position = point.global_position
				new_chunk.add_child(item_instance)
	last_chunk = new_chunk
	active_chunks.append(new_chunk)
	
	next_spawn_position.z -= CHUNK_LENGTH



func add_xp(amount: int):
	GlobalData.current_xp += amount
	if GlobalData.current_xp >= GlobalData.xp_to_next_level:
		GlobalData.current_xp -= GlobalData.xp_to_next_level
		GlobalData.current_level = min(GlobalData.current_level + 1, 5)
		# Aquí puedes mostrar un menú de evolución
	GlobalData.save_game()
			


func _despawn_chunk(chunk: Node3D):
	active_chunks.erase(chunk) 
	
	chunk.queue_free()
