# Player.gd (Adjunto al nodo CharacterBody3D en /scenes/player/Player.tscn)

extends CharacterBody3D

## --- Propiedades de Movimiento ---
const SPEED = 8.0 # Velocidad constante hacia adelante (eje -Z)
const JUMP_VELOCITY = 15.0 # Fuerza de salto
const LANE_CHANGE_SPEED = 10.0 # Velocidad de transición entre carriles
const GRAVITY = 30.0 # Gravedad (ajustada para un juego más rápido)
const LANE_WIDTH = 5.0 # Distancia entre carriles (ej. -5.0, 0.0, 5.0)

## --- Carriles y Estado ---
const LANES = [-LANE_WIDTH, 0.0, LANE_WIDTH]
var current_lane_index = 1 # Empieza en el carril central (índice 1)
var target_x = LANES[1] # Posición X objetivo
var is_sliding = false
var slide_timer = 0.0
const SLIDE_DURATION = 0.8 # Duración del agacharse en segundos

## --- Referencias de Nodos ---
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
# Referencia al nodo Visuals donde se pondrá el modelo del personaje
@onready var visuals_node: Node3D = $Visuals 

# Variables para gestionar el cambio de colisión durante el 'slide'
var standing_collision_shape: BoxShape3D

func _ready():
	# Guarda la forma de colisión de pie para restaurarla
	if collision_shape and collision_shape.shape is BoxShape3D:
		standing_collision_shape = collision_shape.shape.duplicate()
	else:
		# Esto es importante para que sepas si algo falló en la configuración de la escena Player.tscn
		push_error("¡ERROR! Player.tscn debe tener un CollisionShape3D con un BoxShape3D.")
	
	# --- PRUEBA: Instanciar un personaje al inicio ---
	# Esto debe ser reemplazado más tarde por la lógica de selección de personaje
	_load_visual_character(preload("res://scenes/characters/character_k_2.tscn"))

func _load_visual_character(character_scene: Resource):
	# Primero, elimina cualquier visual anterior
	for child in visuals_node.get_children():
		child.queue_free()
		
	# Instancia el nuevo personaje y lo añade al nodo Visuals
	var character_instance = character_scene.instantiate()
	visuals_node.add_child(character_instance)

func _physics_process(delta: float):
	# 1. Aplicar Gravedad
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
		
	# 2. Movimiento Constante Hacia Adelante (Eje -Z)
	var direction = Vector3(0, 0, -1) 
	velocity.z = direction.z * SPEED
	
	# 3. Movimiento Lateral (Cambio de Carril Suave)
	# Mueve la posición X actual hacia el objetivo (target_x) usando lerp
	position.x = lerp(position.x, target_x, LANE_CHANGE_SPEED * delta)
	
	# 4. Manejar Entrada y Slide
	handle_input()
	handle_slide(delta)
	
	move_and_slide()

## --- Funciones de Control ---

func handle_input():
	# Salto
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and not is_sliding: 
		velocity.y = JUMP_VELOCITY
		
	# Cambio de Carril
	if Input.is_action_just_pressed("ui_right"): 
		change_lane(1) # Mover a la derecha
	elif Input.is_action_just_pressed("ui_left"): 
		change_lane(-1) # Mover a la izquierda
		
	# Agacharse (Slide)
	if Input.is_action_just_pressed("ui_down") and is_on_floor() and not is_sliding: 
		start_slide()

func change_lane(direction: int):
	# Limita el índice de carril al rango [0, 2]
	current_lane_index = clamp(current_lane_index + direction, 0, 2)
	target_x = LANES[current_lane_index]

func start_slide():
	is_sliding = true
	slide_timer = 0.0
	
	# Ajustar la forma de colisión para el slide
	if collision_shape.shape is BoxShape3D:
		var original_extents: Vector3 = standing_collision_shape.extents
		var slide_height = original_extents.y / 2.0 
		var slide_center = -original_extents.y / 2.0 
		
		var slide_shape: BoxShape3D = standing_collision_shape.duplicate()
		slide_shape.extents = Vector3(original_extents.x, slide_height, original_extents.z)
		collision_shape.shape = slide_shape
		collision_shape.position.y = slide_center # Baja la caja de colisión

func handle_slide(delta: float):
	if is_sliding:
		slide_timer += delta
		if slide_timer >= SLIDE_DURATION:
			end_slide()

func end_slide():
	is_sliding = false
	# Restaurar la forma de colisión original
	if standing_collision_shape:
		collision_shape.shape = standing_collision_shape
		collision_shape.position.y = 0.0 # Colisión de nuevo en el centro
