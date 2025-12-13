extends Node3D

var character_root: Node3D = Node3D.new()
var loaded_weapons: Array[Node3D] = []

const ROTATION_SPEED = 0.015 
const SPACING = 2.0
const WEAPON_ROTATION_SPEED = 1.0 


const WEAPON_SCENES = [
	"res://src/weapons/blaster_d_2.tscn",
	"res://src/weapons/blaster_b.tscn",
	"res://src/weapons/blaster_i.tscn",
    "res://src/weapons/blaster_a.tscn" 
]

func _ready():
	add_child(character_root)
	
	load_all_weapon_scenes()

func load_all_weapon_scenes():
	for child in character_root.get_children():
		child.queue_free() 
	loaded_weapons.clear() 

	var positions = [
		Vector3(SPACING, 0, SPACING), 
		Vector3(-SPACING, 0, SPACING), 
		Vector3(SPACING, 0, -SPACING), 
		Vector3(-SPACING, 0, -SPACING) 
	]
	
	for i in range(min(WEAPON_SCENES.size(), positions.size())):
		var weapon_path = WEAPON_SCENES[i]
		
		if ResourceLoader.exists(weapon_path):
			var weapon_scene = load(weapon_path)
			
			if weapon_scene is PackedScene:
				var weapon_instance = weapon_scene.instantiate()
				
				weapon_instance.position = positions[i]
				
				character_root.add_child(weapon_instance)
				
				loaded_weapons.append(weapon_instance)
				
				weapon_instance.rotation_degrees.y = i * 90.0
				
			else:
				push_error("¡ERROR! La ruta '" + weapon_path + "' no es una escena (PackedScene).")
		else:
			push_error("¡ERROR! No se pudo encontrar o cargar el recurso: " + weapon_path)

func _process(delta: float):

	for weapon in loaded_weapons:
		if is_instance_valid(weapon):
			weapon.rotate_y(WEAPON_ROTATION_SPEED * delta)
