extends Control
@onready var key_Comandos=$Key
@onready var power_3_key=$Key/PowerKey
const cooldown_comandos: float = 5.0
var comandos_en_cooldown: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("HUD: HUD INICIALIZADO CORRECTAMENTE")
	_mostrar_comandos_temporalmente()

func _mostrar_comandos_temporalmente():
	if comandos_en_cooldown==false:
		if GlobalData.character_power_3!="" and GlobalData.character_power_3!="saqueo":
			power_3_key.show()
		else:
			power_3_key.hide()
		key_Comandos.show()
		print("comandos visibles")
		await get_tree().create_timer(cooldown_comandos).timeout
		comandos_en_cooldown=true
		key_Comandos.hide()
		print("comandos ocultos")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
