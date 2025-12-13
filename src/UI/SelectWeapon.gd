
extends Control
const GAME_SCENE_PATH="res://scenes/game_scene.tscn"
const MAIN_SCENE_PATH="res://src/UI/MainMenu.tscn"
const WEAPON_PATHS={
	"blaster_a":"res://src/weapons/blaster_a.tscn",
	"blaster_i":"res://src/weapons/blaster_i.tscn",
	"blaster_b":"res://src/weapons/blaster_b.tscn",
	"blaster_a_2":"res://src/weapons/blaster_a.tscn"
}




func _ready() -> void:
	pass 


func _process(delta: float) -> void:
	pass


func _on_blaster_a_pressed() :
	print("Seleccionada arma: blaster_a")
	GlobalData.selected_weapon_scene_path=WEAPON_PATHS["blaster_a"]
	GlobalData.damage_weapon_multiplier=1.8
	print("Ruta de arma seleccionada: "+GlobalData.selected_weapon_scene_path," Multiplicador de daño: "+str(GlobalData.damage_weapon_multiplier))
	GlobalData.save_game()


func _on_blaster_i_pressed():
	print("Seleccionada arma: blaster_i")
	GlobalData.selected_weapon_scene_path=WEAPON_PATHS["blaster_i"]
	GlobalData.damage_weapon_multiplier=2.8
	print("Ruta de arma seleccionada: "+GlobalData.selected_weapon_scene_path," Multiplicador de daño: "+str(GlobalData.damage_weapon_multiplier))
	GlobalData.save_game()


func _on_blaster_b_pressed() :
	print("Seleccionada arma: blaster_b")
	GlobalData.selected_weapon_scene_path=WEAPON_PATHS["blaster_b"]
	GlobalData.damage_weapon_multiplier=3.8
	print("Ruta de arma seleccionada: "+GlobalData.selected_weapon_scene_path," Multiplicador de daño: "+str(GlobalData.damage_weapon_multiplier))
	GlobalData.save_game()


func _on_blaster_a_2_pressed() :
	print("Seleccionada arma: blaster_a_2")
	GlobalData.selected_weapon_scene_path=WEAPON_PATHS["blaster_a_2"]
	GlobalData.damage_weapon_multiplier=5
	print("Ruta de arma seleccionada: "+GlobalData.selected_weapon_scene_path," Multiplicador de daño: "+str(GlobalData.damage_weapon_multiplier))
	GlobalData.save_game()


func _on_back_button_pressed():
	if not GlobalData.selected_weapon_scene_path:
		GlobalData.selected_weapon_scene_path=WEAPON_PATHS["blaster_a"] 
	print("Regresando al menú principal con: "+GlobalData.selected_weapon_scene_path)
	GlobalData.save_game()
	get_tree().change_scene_to_file(MAIN_SCENE_PATH)
