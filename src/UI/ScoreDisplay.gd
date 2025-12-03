
extends Label

func _process(delta):

	text = "Basura: " + str(GlobalData.current_score) + "\nGlobal XP: " + str(GlobalData.total_global_trash)
