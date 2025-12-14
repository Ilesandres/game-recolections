extends Control
const GAME_SCENE_PATH="res://scenes/game_scene.tscn"
const MAIN_SCENE_PATH="res://src/UI/MainMenu.tscn"

const WEAPON_PATHS = {
	"blaster_a": "res://src/weapons/blaster_a.tscn",
	"blaster_i": "res://src/weapons/blaster_i.tscn",
	"blaster_b": "res://src/weapons/blaster_b.tscn",
	"blaster_a_2": "res://src/weapons/blaster_d_2.tscn"
}

const WEAPON_COSTS = {
	"blaster_a": 0,
	"blaster_i": 10,
	"blaster_b": 50,
	"blaster_a_2": 100
}

@onready var blaster_a_button: Button = $blaster_a
@onready var blaster_i_button: Button = $blaster_i
@onready var blaster_b_button: Button = $blaster_b
@onready var blaster_a_2_button: Button = $blaster_a_2
@onready var global_score_label: Label = $GlobalScore 


func _ready() -> void:
	GlobalData.load_game() 
	
	update_global_score_display()
	
	check_and_lock_weapons()

func update_global_score_display():
	global_score_label.text = "score Global Acumulada: " + str(GlobalData.total_global_trash) + "\namplificador de daño : " + str(GlobalData.damage_weapon_multiplier)

func update_details_character():
	print("hola")
func check_and_lock_weapons():
	var player_score = GlobalData.total_global_trash
	
	blaster_a_button.disabled = false 
	
	if player_score < WEAPON_COSTS["blaster_i"]:
		blaster_i_button.disabled = true
	else:
		blaster_i_button.disabled = false

	if player_score < WEAPON_COSTS["blaster_b"]:
		blaster_b_button.disabled = true
	else:
		blaster_b_button.disabled = false
		
	if player_score < WEAPON_COSTS["blaster_a_2"]:
		blaster_a_2_button.disabled = true
	else:
		blaster_a_2_button.disabled = false


func _on_blaster_a_pressed() :
	print("Seleccionada arma: blaster_a")
	GlobalData.selected_weapon_scene_path = WEAPON_PATHS["blaster_a"]
	GlobalData.damage_weapon_multiplier = 1.8
	GlobalData.weapon_cooldown = true
	GlobalData.weapon_sound_shoot_path= "res://assets/audio/weapons/shoots/shoot-arma-blaster-a.mp3"
	print("Ruta de arma seleccionada: " + GlobalData.selected_weapon_scene_path, " Multiplicador de daño: " + str(GlobalData.damage_weapon_multiplier))
	update_global_score_display()
	GlobalData.save_game()


func _on_blaster_i_pressed():
	if GlobalData.total_global_trash < WEAPON_COSTS["blaster_i"]:
		print("ERROR: Score insuficiente para blaster_i")
		return
		
	print("Seleccionada arma: blaster_i")
	GlobalData.selected_weapon_scene_path = WEAPON_PATHS["blaster_i"]
	GlobalData.damage_weapon_multiplier = 2.8
	GlobalData.weapon_cooldown = true
	GlobalData.weapon_sound_shoot_path="res://assets/audio/weapons/shoots/shoot-blaster-i.mp3"
	print("Ruta de arma seleccionada: " + GlobalData.selected_weapon_scene_path, " Multiplicador de daño: " + str(GlobalData.damage_weapon_multiplier))
	update_global_score_display()
	GlobalData.save_game()


func _on_blaster_b_pressed() :
	if GlobalData.total_global_trash < WEAPON_COSTS["blaster_b"]:
		print("ERROR: Score insuficiente para blaster_b")
		return
		
	print("Seleccionada arma: blaster_b")
	GlobalData.selected_weapon_scene_path = WEAPON_PATHS["blaster_b"]
	GlobalData.damage_weapon_multiplier = 3.8
	GlobalData.weapon_cooldown = true
	GlobalData.weapon_sound_shoot_path="res://assets/audio/weapons/shoots/shoot-blaster-b.mp3"
	print("Ruta de arma seleccionada: " + GlobalData.selected_weapon_scene_path, " Multiplicador de daño: " + str(GlobalData.damage_weapon_multiplier))
	update_global_score_display()
	GlobalData.save_game()


func _on_blaster_a_2_pressed() :
	if GlobalData.total_global_trash < WEAPON_COSTS["blaster_a_2"]:
		print("ERROR: Score insuficiente para blaster_a_2")
		return
		
	print("Seleccionada arma: blaster_a_2")
	GlobalData.selected_weapon_scene_path = WEAPON_PATHS["blaster_a_2"]
	GlobalData.damage_weapon_multiplier = 5
	GlobalData.weapon_cooldown = false 
	GlobalData.weapon_sound_shoot_path="res://assets/audio/weapons/shoots/shoot-blaster-d.mp3"
	print("Ruta de arma seleccionada: " + GlobalData.selected_weapon_scene_path, " Multiplicador de daño: " + str(GlobalData.damage_weapon_multiplier))
	update_global_score_display()
	GlobalData.save_game()


func _on_back_button_pressed():
	if not GlobalData.selected_weapon_scene_path:
		GlobalData.selected_weapon_scene_path = WEAPON_PATHS["blaster_a"] 
	print("Regresando al menú principal con: " + GlobalData.selected_weapon_scene_path)
	GlobalData.save_game()
	get_tree().change_scene_to_file(MAIN_SCENE_PATH)
