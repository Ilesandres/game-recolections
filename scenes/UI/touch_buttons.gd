extends CanvasLayer

@onready var power3_1_touch=$"power-1-3"

# Called when the node enters the scene tree for the first time.
func _ready():
	if OS.has_feature("mobile"):
		visible=true
	else:
		visible=false
	_verify_activate_power()

func _verify_activate_power():
	GlobalData.load_game()
	if GlobalData.character_power_3 !="" and GlobalData.character_power_3 !=null:
		if GlobalData.character_power_3=="Shunpo":
			power3_1_touch.visible=true
	else:
		power3_1_touch.visible=false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
