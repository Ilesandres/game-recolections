extends Node3D

const CHUNK_SCENE = preload("res://scenes/world/chunk_template.tscn")
const OBSTACLE_SCENE = preload("res://scenes/world/Obstacle.tscn") 
const ENEMY_SCENE = preload("res://scenes/world/Enemy.tscn")
const CHUNK_LENGTH = 30.0 

@onready var player: CharacterBody3D = get_parent().find_child("PlayerContainer", true).get_node("Player") 


var last_chunk: Node3D = null     
var active_chunks: Array[Node3D] = [] 
var next_spawn_position: Vector3 = Vector3.ZERO
var current_level: int = 1

var spawn_speed = 1.0
var object_spawn_chance = 0.33
var spawn_attempts = 1
var min_distance = 2.5 

func configure_for_level(level: int):
	match level:
		1:
			spawn_speed = 10.0
			object_spawn_chance = 0.2
			spawn_attempts = 1
		2:
			spawn_speed = 15.0
			object_spawn_chance = 0.3
			spawn_attempts = 1
		3:
			spawn_speed = 20.0
			object_spawn_chance = 0.4
			spawn_attempts = 2
		4:
			spawn_speed = 25.0
			object_spawn_chance = 0.5
			spawn_attempts = 2
		5:
			spawn_speed = 30.0
			object_spawn_chance = 0.6
			spawn_attempts = 3


func _ready():
	configure_for_level(GlobalData.current_level)
	print("Configuración de nivel:", GlobalData.current_level, " Velocidad de spawn:", spawn_speed, " Probabilidad de objetos:", object_spawn_chance, " Intentos de spawn:", spawn_attempts)
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
	var newly_spawned_objects: Array[Node3D] = [] 

	for point in obstacle_points:
		var successful_spawns = 0
		
		for i in range(spawn_attempts):
			if randf() < object_spawn_chance:
				var item_roll = randf()
				var item_instance = null
				
				if item_roll < 0.8:
					item_instance = OBSTACLE_SCENE.instantiate()
				else:
					item_instance = ENEMY_SCENE.instantiate()
				
				if item_instance:
					item_instance.global_position = point.global_position
					
					if is_position_free(item_instance.global_position, new_chunk, newly_spawned_objects): 
						new_chunk.add_child(item_instance)
						newly_spawned_objects.append(item_instance) 
						successful_spawns += 1
					else:
						item_instance.queue_free()
						
					if successful_spawns > 0:
						break

	last_chunk = new_chunk
	active_chunks.append(new_chunk)
	
	next_spawn_position.z -= CHUNK_LENGTH


func add_xp(amount: int):
	GlobalData.current_xp += amount
	if GlobalData.current_xp >= GlobalData.xp_to_next_level:
		GlobalData.current_xp -= GlobalData.xp_to_next_level
		GlobalData.current_level = min(GlobalData.current_level + 1, 5)
	GlobalData.save_game()
			

func _despawn_chunk(chunk: Node3D):
	active_chunks.erase(chunk) 
	chunk.queue_free()

func is_position_free(new_pos: Vector3, chunk: Node3D, temporary_objects: Array[Node3D] = []) -> bool:
	var count_x = 0
	
	for child in chunk.get_children():
		if child.has_method("global_position"):
			if abs(child.global_position.x - new_pos.x) < 0.1:
				count_x += 1
			if child.global_position.distance_to(new_pos) < min_distance:
				return false
		
	for temp_obj in temporary_objects:
		if abs(temp_obj.global_position.x - new_pos.x) < 0.1:
			count_x += 1
		if temp_obj.global_position.distance_to(new_pos) < min_distance:
			return false
	
	if count_x >= 3:
		return false
		
	return true
