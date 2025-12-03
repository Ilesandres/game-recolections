# LevelSpawner.gd (Adjunto al nodo LevelSpawner en game_scene.tscn)

extends Node3D

# 1. Carga Previa de la Escena Chunk
const CHUNK_SCENE = preload("res://scenes/world/chunk_template.tscn")
const CHUNK_LENGTH = 30.0 # Longitud de tu chunk_template.tscn

# 2. Referencia al Jugador
@onready var player: CharacterBody3D = get_parent().find_child("PlayerContainer", true).get_node("Player") 

var last_chunk: Node3D = null       
var active_chunks: Array[Node3D] = [] 
var next_spawn_position: Vector3 = Vector3.ZERO # Rastrea dónde debe aparecer el siguiente trozo

func _ready():
	# 🚨 SOLUCIÓN ROBUSTA: Generamos los 3 primeros trozos usando 'next_spawn_position'
	# Esta variable se actualiza automáticamente DENTRO de _spawn_chunk()
	_spawn_chunk(next_spawn_position)
	_spawn_chunk(next_spawn_position)
	_spawn_chunk(next_spawn_position)
	
# CORRECCIÓN DE ALERTA 1: Usamos _delta en lugar de delta.
func _process(_delta: float): 
	# La validación del jugador va PRIMERO
	if not is_instance_valid(player): 
		return
		
	# === A. Lógica de Generación ===
	# Generamos el siguiente chunk cuando el jugador pasa la mitad del último (-15.0).
	if last_chunk and player.global_position.z < last_chunk.global_position.z - 15.0:
		_spawn_chunk(next_spawn_position)

	# === B. Lógica de Eliminación (Despawn) ===
	if active_chunks.size() > 0:
		var oldest_chunk = active_chunks[0]
		
		# 🚨 SOLUCIÓN CRÍTICA: Verificamos que el chunk es válido Y que tiene el nodo 'DespawnPoint'
		if is_instance_valid(oldest_chunk) and oldest_chunk.has_node("DespawnPoint"):
			
			var despawn_point_z = oldest_chunk.get_node("DespawnPoint").global_position.z
			
			if player.global_position.z < despawn_point_z:
				_despawn_chunk(oldest_chunk)
		# NOTA: Si no es válido o no tiene el nodo, el chunk se queda en active_chunks 
		# hasta que se libera o se gestiona manualmente. Para la mayoría de los casos es seguro.
				
# --- Funciones de Gestión ---

# CORRECCIÓN DE ALERTA 2: Cambiamos 'position' por 'target_position'
func _spawn_chunk(target_position: Vector3): 
	var new_chunk = CHUNK_SCENE.instantiate()
	add_child(new_chunk)
	
	# Asigna la posición de generación
	new_chunk.global_position = target_position 
	
	# Actualiza variables de seguimiento
	last_chunk = new_chunk
	active_chunks.append(new_chunk)
	
	# 🚨 CRÍTICO: Actualizamos la posición para el siguiente trozo (30m adelante).
	next_spawn_position.z -= CHUNK_LENGTH

func _despawn_chunk(chunk: Node3D):
	# 🚨 SOLUCIÓN CRÍTICA: Eliminamos la referencia del array PRIMERO
	# Esto asegura que active_chunks[0] apunte al siguiente chunk válido en la próxima iteración.
	active_chunks.erase(chunk) 
	
	# Luego, eliminamos el nodo de la escena
	chunk.queue_free()
