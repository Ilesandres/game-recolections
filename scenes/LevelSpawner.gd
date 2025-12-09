extends Node3D

const CHUNK_SCENE = preload("res://scenes/world/chunk_template.tscn")
const OBSTACLE_SCENE = preload("res://scenes/world/Obstacle.tscn") 
const ENEMY_SCENE = preload("res://scenes/world/Enemy.tscn")
const CHUNK_LENGTH = 30.0 

const DESPAWN_DISTANCE = 4.0 * CHUNK_LENGTH 

@onready var player: CharacterBody3D = get_parent().find_child("PlayerContainer", true).get_node("Player") 

var last_chunk: Node3D = null 
var active_chunks: Array[Node3D] = [] 

var chunk_map: Dictionary = {} 
var last_chunk_center: Vector3 = Vector3.INF 
var current_level: int = 1

var spawn_speed = 1.0
var object_spawn_chance = 0.33
var spawn_attempts = 1
var min_distance = 2.5 


func configure_for_level(level: int):
	match level:
		1:
			object_spawn_chance = 0.2
			spawn_attempts = 1
		2:
			object_spawn_chance = 0.3
			spawn_attempts = 1
		3:
			object_spawn_chance = 0.4
			spawn_attempts = 2
		4:
			object_spawn_chance = 0.5
			spawn_attempts = 2
		5:
			object_spawn_chance = 0.6
			spawn_attempts = 3


func _get_snapped_position(position: Vector3) -> Vector3:
	return position.snapped(Vector3(CHUNK_LENGTH, 0, CHUNK_LENGTH))


func _ready():
	configure_for_level(GlobalData.current_level)
	print("Configuración de nivel:", GlobalData.current_level, " Probabilidad de objetos:", object_spawn_chance, " Intentos de spawn:", spawn_attempts)

	_spawn_chunk(Vector3.ZERO)
	_check_and_spawn_neighbors(Vector3.ZERO)


func _process(_delta: float):
	if not is_instance_valid(player):
		return

	var player_pos = player.global_position
	
	var current_chunk_center = _get_snapped_position(player_pos)
	
	if last_chunk_center != current_chunk_center:
		last_chunk_center = current_chunk_center
		_check_and_spawn_neighbors(current_chunk_center)
		
	_cleanup_old_chunks(player_pos)


func _check_and_spawn_neighbors(center_pos: Vector3):
	var directions = [
		Vector3(CHUNK_LENGTH, 0, 0), Vector3(-CHUNK_LENGTH, 0, 0), Vector3(0, 0, CHUNK_LENGTH), Vector3(0, 0, -CHUNK_LENGTH),
		Vector3(CHUNK_LENGTH, 0, CHUNK_LENGTH), Vector3(-CHUNK_LENGTH, 0, CHUNK_LENGTH), Vector3(CHUNK_LENGTH, 0, -CHUNK_LENGTH), Vector3(-CHUNK_LENGTH, 0, -CHUNK_LENGTH),
		Vector3.ZERO 
	]
	
	for dir in directions:
		var neighbor_pos = center_pos + dir
		
		if not chunk_map.has(neighbor_pos):
			_spawn_chunk(neighbor_pos)


func _cleanup_old_chunks(player_pos: Vector3):
	var chunks_to_remove: Array[Node3D] = []
	
	for chunk in active_chunks:
		var distance = Vector2(chunk.global_position.x, chunk.global_position.z).distance_to(Vector2(player_pos.x, player_pos.z))
		
		if distance > DESPAWN_DISTANCE:
			chunks_to_remove.append(chunk)

	for chunk in chunks_to_remove:
		_despawn_chunk(chunk)


func _spawn_chunk(target_position: Vector3): 
	var new_chunk = CHUNK_SCENE.instantiate()
	
	add_child(new_chunk)
	new_chunk.global_position = target_position 
	
	chunk_map[target_position] = new_chunk
	active_chunks.append(new_chunk)
	
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
					var spawn_pos = point.global_position
					if item_instance.has_node("CollisionShape3D"):
						var shape = item_instance.get_node("CollisionShape3D").shape
						if shape is BoxShape3D:
							spawn_pos.y += shape.size.y / 2.0
						elif shape is CapsuleShape3D:
							spawn_pos.y += shape.height / 2.0 + shape.radius
						# Puedes agregar más casos según tus colliders
					item_instance.global_position = spawn_pos
					if is_position_free(item_instance.global_position, new_chunk, newly_spawned_objects):
						new_chunk.add_child(item_instance)
						newly_spawned_objects.append(item_instance)
						successful_spawns += 1
					else:
						item_instance.queue_free()
					if successful_spawns > 0:
						break

	last_chunk = new_chunk
	

func add_xp(amount: int):
	GlobalData.current_xp += amount
	if GlobalData.current_xp >= GlobalData.xp_to_next_level:
		GlobalData.current_xp -= GlobalData.xp_to_next_level
		GlobalData.current_level = min(GlobalData.current_level + 1, 5)
	GlobalData.save_game()


func _despawn_chunk(chunk: Node3D):
	active_chunks.erase(chunk) 
	var chunk_key = chunk.global_position.snapped(Vector3(CHUNK_LENGTH, 0, CHUNK_LENGTH))
	if chunk_map.has(chunk_key):
		chunk_map.erase(chunk_key)

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
