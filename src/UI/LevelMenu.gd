extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_level_1_pressed() :
	GlobalData.current_level=1
	print("Nivel actual:", GlobalData.current_level)
	get_tree().change_scene_to_file("res://scenes/game_scene.tscn")


func _on_level_2_pressed() :
	GlobalData.current_level=2
	print("Nivel actual:", GlobalData.current_level)
	get_tree().change_scene_to_file("res://scenes/game_scene.tscn")


func _on_level_3_pressed():
	GlobalData.current_level=3
	print("Nivel actual:", GlobalData.current_level)
	get_tree().change_scene_to_file("res://scenes/game_scene.tscn")


func _on_level_4_pressed() :
	GlobalData.current_level=4
	print("Nivel actual:", GlobalData.current_level)
	get_tree().change_scene_to_file("res://scenes/game_scene.tscn")


func _on_level_5_pressed() :
	GlobalData.current_level=5
	print("Nivel actual:", GlobalData.current_level)
	get_tree().change_scene_to_file("res://scenes/game_scene.tscn")
