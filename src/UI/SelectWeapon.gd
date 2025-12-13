
extends Control
const GAME_SCENE_PATH="res://scenes/game_scene.tscn"
const MAIN_SCENE_PATH="res://src/UI/MainMenu.tscn"
const WEAPON_PATHS={
	"blaster_a":"res://src/weapons/blaster_a.tscn",
	"blaster_i":"res://src/weapons/blaster_i.tscn",
	"blaster_b":"res://src/weapons/blaster_b.tscn",
	"blaster_a_2":"res://src/weapons/blaster_a.tscn"
}




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_blaster_a_pressed() :
	print("Seleccionada arma: blaster_a")
	GlobalData.selected_weapon_scene_path=WEAPON_PATHS["blaster_a"]
	print("Ruta de arma seleccionada: "+GlobalData.selected_weapon_scene_path)


func _on_blaster_i_pressed():
	print("Seleccionada arma: blaster_i")
	GlobalData.selected_weapon_scene_path=WEAPON_PATHS["blaster_i"]
	print("Ruta de arma seleccionada: "+GlobalData.selected_weapon_scene_path)


func _on_blaster_b_pressed() :
	print("Seleccionada arma: blaster_b")
	GlobalData.selected_weapon_scene_path=WEAPON_PATHS["blaster_b"]
	print("Ruta de arma seleccionada: "+GlobalData.selected_weapon_scene_path)


func _on_blaster_a_2_pressed() :
	print("Seleccionada arma: blaster_a_2")
	GlobalData.selected_weapon_scene_path=WEAPON_PATHS["blaster_a_2"]
	print("Ruta de arma seleccionada: "+GlobalData.selected_weapon_scene_path)


func _on_back_button_pressed():
	if not GlobalData.selected_weapon_scene_path:
		GlobalData.selected_weapon_scene_path=WEAPON_PATHS["blaster_a"] 
	print("Regresando al menú principal con: "+GlobalData.selected_weapon_scene_path)
	get_tree().change_scene_to_file(MAIN_SCENE_PATH)
