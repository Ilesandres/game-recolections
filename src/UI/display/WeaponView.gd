
extends Node3D

var character_root: Node3D = Node3D.new()

const ROTATION_SPEED = 0.015 

func _ready():

	add_child(character_root)
	
	load_selected_character()

func load_selected_character():
	for child in character_root.get_children():
		child.queue_free() 

	var char_path = GlobalData.selected_weapon_scene_path
	
	if char_path and ResourceLoader.exists(char_path):
		var character_scene = load(char_path)
		
		if character_scene is PackedScene:
			var character_instance = character_scene.instantiate()
			
			character_root.add_child(character_instance)
			
		else:
			push_error("¡ERROR! La ruta de personaje cargada no es una escena (PackedScene).")
	else:
		push_error("¡ERROR! No se pudo encontrar o cargar el recurso: " + char_path)

func _process(delta):
	character_root.rotate_y(ROTATION_SPEED)
