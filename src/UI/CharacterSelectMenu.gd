
extends Control

const GAME_SCENE_PATH = "res://scenes/game_scene.tscn" 
const MAIN_SCENE_PATH= "res://src/UI/MainMenu.tscn"

const CHARACTER_PATHS = {
	"K": "res://scenes/characters/character_k_2.tscn",
	"O": "res://scenes/characters/character_o_2.tscn",
	"P": "res://scenes/characters/character_p_2.tscn",
	"R": "res://scenes/characters/character_r_2.tscn",
}
const CHARACTER_HEALTH = {
	"K": 3,
	"O": 5,
	"P": 8,
	"R": 12,
}

const CHARACTER_COSTS={
	"K":0,
	"O":20,
	"P":10000,
	"R":1000000,
}
const CHARACTER_POWERS_1={
	"K":"ShootOne",
	"O":"ShootTwo",
	"P":"ShootThree",
	"R":"ShootFour",
}
const CHARACTER_POWERS_1_DESCRIPTION={
	"K":"Disparo unico",
	"O":"Disparo doble",
	"P":"Disparo triple",
	"R":"Disparo cuadruple",
}
const CHARACTER_POWERS_2={
	"K":"nomalSpeed",
	"O":"MediunSpeed",
	"P":"FastSpeed",
	"R":"MaxSpeed",
}
const CHARACTER_POWERS_2_DESCRIPTION={
	"K":"Velocidad normal",
	"O":"Velocidad media",
	"P":"Velocidad rapida",
	"R":"Velocidad maxima",
}
const CHARACTER_POWERS_3={
	"P":"saqueo",
	"R":"Shunpo"
}
const CHARACTER_POWERS_3_DESCRIPTION={
	"P":"al destruir un mob hay una posibilidad \n de recuperar una vida si no estas\na vida completa",
	"R":"Teletransportacion corta distancia"
}
@onready var character_disply_3d=$DisplayContainer/CharacterViewport/CharacterDisplay3D
@onready var global_score = $ScoreGlobal
@onready var character_details =$DetailsCharacter
@onready var health_character_display=$GridContainer/HealthCharacterContainer/HealtCharacter
@onready var name_character_display=$GridContainer/NameContainer/NameCharacter

@onready var character_k_button=$SelectCharacterK
@onready var score_character_k=$ScoreK
@onready var character_o_button=$SelectCharacterO
@onready var score_character_o=$ScoreO
@onready var character_p_button=$SelectCharacterP
@onready var score_character_p=$ScoreP
@onready var character_r_button=$SelectCharacterR
@onready var score_character_r=$ScoreR

@onready var power_3=$GridContainer/Power1/PowersDescriptions/Power3
@onready var power_1=$GridContainer/Power1/PowersDescriptions/Power1
@onready var power_2=$GridContainer/Power1/PowersDescriptions/Power2
@onready var descripcion_power_display=$GridContainer/Power1/DescritpionDysplay
@onready var description_label=$GridContainer/Power1/DesccriptionLabel

var current_selection_key: String = "K" 
func _ready():
	GlobalData.load_game()
	update_global_score_display()
	description_label.hide()
	update_details_character()
	check_and_lock_characters()
	loadScores()

func loadScores():
	score_character_k.text='score : '+str(CHARACTER_COSTS["K"])	
	score_character_o.text='score : '+str(CHARACTER_COSTS["O"])
	score_character_p.text='score : '+str(CHARACTER_COSTS["P"])
	score_character_r.text='score : '+str(CHARACTER_COSTS["R"])

func select_character(key: String):
	current_selection_key = key
	print("Seleccionado personaje: " + key)
	
	GlobalData.selected_character_scene_path = CHARACTER_PATHS[key]
	GlobalData.character_health= CHARACTER_HEALTH[key]
	GlobalData.character_power_1=CHARACTER_POWERS_1[key]
	GlobalData.character_power_1_description=CHARACTER_POWERS_1_DESCRIPTION[key]
	GlobalData.character_power_2=CHARACTER_POWERS_2[key]
	GlobalData.character_power_2_description=CHARACTER_POWERS_2_DESCRIPTION[key]
	if CHARACTER_POWERS_3.has(key):
		GlobalData.character_power_3=CHARACTER_POWERS_3[key]
		GlobalData.character_power_3_description=CHARACTER_POWERS_3_DESCRIPTION[key]
	else:
		GlobalData.character_power_3=""
		GlobalData.character_power_3_description=""
	
	update_details_character()
	description_label.hide()
	descripcion_power_display.text=""
	if is_instance_valid(character_disply_3d):
		character_disply_3d.load_selected_character()
	else:
		print(" error al cargar el personaje seleccionado")
	
func update_global_score_display():
	global_score.text = "score : "+ str(GlobalData.total_global_trash)

func update_details_character():
	health_character_display.text="Vida: "+str(CHARACTER_HEALTH[current_selection_key])
	name_character_display.text=current_selection_key
	character_details.text="Personaje: "+current_selection_key
	power_3.text="hola"
	power_1.text=GlobalData.character_power_1
	power_2.text=GlobalData.character_power_2
	if GlobalData.character_power_3!="":
		power_3.visible=true
		power_3.text=GlobalData.character_power_3
	else:
		power_3.visible=false
	

func _on_play_button_pressed():
	if not GlobalData.selected_character_scene_path:
		select_character("K") 
		
	print("Iniciando juego con: " + GlobalData.selected_character_scene_path)
	GlobalData.save_game()
	get_tree().change_scene_to_file(GAME_SCENE_PATH)


func _on_select_character_r_pressed() :
	select_character("R")


func _on_select_character_k_pressed() :
	print("seleccionando k"+GlobalData.selected_character_scene_path)
	select_character("K")


func _on_select_character_o_pressed() :
	select_character("O")
	

func _on_select_character_p_pressed() :
	select_character("P")


func _on_back_button_pressed():
	if not GlobalData.selected_character_scene_path:
		select_character("K") 
	GlobalData.save_game()
	print("Regresando al menú principal con: " + GlobalData.selected_character_scene_path)
	get_tree().change_scene_to_file(MAIN_SCENE_PATH)
	

func check_and_lock_characters():
	var player_score= GlobalData.total_global_trash
	character_k_button.disabled=false
	if player_score<CHARACTER_COSTS["O"]:
		character_o_button=true
	else:
		character_o_button=false
	
	if player_score<CHARACTER_COSTS["P"]:
		character_p_button.disabled=true
	else:
		character_p_button.disabled=false
	
	if player_score<CHARACTER_COSTS["R"]:
		character_r_button.disabled=true
	else:
		character_r_button.disabled=false


func _on_power_1_pressed() :
	description_label.show()
	descripcion_power_display.text=GlobalData.character_power_1_description


func _on_power_2_pressed() :
	description_label.show()
	descripcion_power_display.text=GlobalData.character_power_2_description


func _on_power_3_pressed() :
	description_label.show()
	descripcion_power_display.text=GlobalData.character_power_3_description
