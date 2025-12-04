
extends Label

func _process(delta):

	text = "Basura: " + str(GlobalData.current_score) + "\nGlobal XP: " + str(GlobalData.total_global_trash)

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		print("aceptando desde scorelabel")
