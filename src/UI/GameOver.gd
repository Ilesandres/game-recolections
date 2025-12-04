extends Control
const GAME_SCENE_PATH= "res://scenes/game_scene.tscn"
const MAIN_MENU_SCENE_PATH= "res://src/UI/MainMenu.tscn"
const HUD_SCENE_PATH="res://src/UI/HUD.tscn"
const HUD_SCENE=preload(HUD_SCENE_PATH)

var hud_screen=null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	hud_screen= HUD_SCENE.instantiate()
	add_child(hud_screen)
	get_tree().paused=false



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass




func _on_try_again_pressed():
	print(" intentnado de nuevo scene GameOver")
	get_tree().reload_current_scene()
	GlobalData.current_score=0
	pass # Replace with function body.


func _on_main_menu_pressed() -> void:
	print("dirigiendo a menu scene GameOver")
	get_tree().paused=false
	get_tree().change_scene_to_file("res://src/UI/MainMenu.tscn")
	pass # Replace with function body.

func setup_game_over_screen(final_score: int, high_score: int):
	var hud_control = hud_screen
	hud_control.hide()
	var score_label = $ScoreLabel
	var level_label = $LevelLabel
	score_label.text = "Puntuación Final: %d" % final_score
	level_label.text = "Puntuación Más Alta: %d" % high_score
	show()
	get_tree().paused = true
