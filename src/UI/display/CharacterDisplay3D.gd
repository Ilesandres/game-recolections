# Archivo: CharacterDisplay3D.gd
extends Node3D

# --- PROPIEDADES ---
# El nodo que contendrá el modelo 3D (para que pueda rotar solo)
var character_root: Node3D = Node3D.new()

# Tiempo que tarda en completar una vuelta (en segundos)
const ROTATION_SPEED = 0.015 

# --- FUNCIÓN READY ---
func _ready():
	# 1. Aseguramos que GlobalData se cargue y esté disponible.
	# Si GlobalData es un Autoload (Singletón), ya está disponible globalmente.
	
	# 2. Añadir el nodo raíz de rotación al árbol la primera vez
	add_child(character_root)
	
	# 3. Cargar el personaje seleccionado por defecto
	load_selected_character()

# --- LÓGICA DE CARGA Y LIMPIEZA ---
func load_selected_character():
	# 1. Limpiar el personaje antiguo (si existe)
	for child in character_root.get_children():
		child.queue_free() # Elimina el modelo anterior de la escena

	# 2. Obtener la ruta del personaje seleccionado del Singletón
	# Asume que GlobalData.gd está configurado como Singletón/Autoload.
	var char_path = GlobalData.selected_character_scene_path 
	
	if char_path and ResourceLoader.exists(char_path):
		var character_scene = load(char_path)
		
		# Debe ser una Scene (packéame) y no un Simple Resource
		if character_scene is PackedScene:
			var character_instance = character_scene.instantiate()
			
			# 3. El personaje se añade al nodo que vamos a rotar
			character_root.add_child(character_instance)
			
			# Opcional: Ajustar la posición vertical para que se vea bien en la cámara
			# character_instance.position.y = -0.5 
		else:
			push_error("¡ERROR! La ruta de personaje cargada no es una escena (PackedScene).")
	else:
		push_error("¡ERROR! No se pudo encontrar o cargar el recurso: " + char_path)

# --- ROTACIÓN CONTINUA ---
func _process(delta):
	# Rotación continua en el eje Y (vertical) para mostrar el modelo
	character_root.rotate_y(ROTATION_SPEED)
