extends Control
@onready var key_Comandos = $Key
@onready var power_3_key = $Key/PowerKey
@onready var cooldown_container=$"cooldown-power"
@onready var cooldown_power = $"cooldown-power/CooldownLabel"
@onready var health=$health
@onready var score_label=$ScoreLabel
const cooldown_comandos: float = 5
var comandos_en_cooldown: bool = false
var game_paused: bool = false
var cooldown_seconds = 5


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GlobalData.character_power_3 != "" and GlobalData.character_power_3 != "saqueo":
		cooldown_power.text = "||||||||||||||||"
		_add_stylebox(Color(0, 1, 0))
		cooldown_container.show()
		var player = get_tree().get_root().get_node("Game/PlayerContainer/Player")
		if player:
			player.connect("reload_cooldown", Callable(self, "_update_cooldown"))
		else:
			print("HUD: No se encontró el nodo Player")
	else:
		cooldown_container.hide()
		print("HUD: No hay poder 3 asignado o es saqueo")
	
	
	_mostrar_comandos_temporalmente()
	var pause_menu= get_tree().get_root().get_node("Game/PauseMenuLayer/PauseMenu")
	if pause_menu.has_signal("pause_game_signal"):
		print("HUD: Señal pause_game_signal  existe en PauseMenu")
	if pause_menu:
		print("HUD: Conectando señales con PauseMenu")
		pause_menu.connect("pause_game_signal", Callable(self, "_hide_ui"))
	else:
		print("HUD: No se encontró el nodo PauseMenu")

func _mostrar_comandos_temporalmente():
	if comandos_en_cooldown == false:
		if GlobalData.character_power_3 != "" and GlobalData.character_power_3 != "saqueo":
			power_3_key.show()
		else:
			power_3_key.hide()
		key_Comandos.show()
		print("HUD: comandos visibles")
		await get_tree().create_timer(cooldown_comandos).timeout
		comandos_en_cooldown = true
		key_Comandos.hide()
		print("HUD: comandos ocultos")

func _update_cooldown():
	_add_stylebox()
	print(" HUD: actualizando cooldown")
	cooldown_power.text = ""
	for i in range(cooldown_seconds, 0, -1):
		cooldown_power.text += str("|||")
		await get_tree().create_timer(1.0).timeout
	_add_stylebox(Color(0, 1, 0))
	

func _add_stylebox(color: Color = Color(1, 1, 0)):
		var style = StyleBoxFlat.new()
		style.border_color = color
		style.border_width_bottom = 5
		style.border_width_left = 5
		style.border_width_right = 5
		style.border_width_top = 5
		cooldown_power.add_theme_stylebox_override("normal", style)

func _clear_stylebox():
	cooldown_power.add_theme_stylebox_override("normal", null)


func _show_ui():
	key_Comandos.show()
	cooldown_container.show()
	health.show()
	score_label.show()
	print("HUD: mostrando hud")

func _hide_ui():
	print("HUD: ocultando hud desde pausa")
	key_Comandos.hide()
	cooldown_container.hide()
	health.hide()
	score_label.hide()
	print("HUD: ocultando hud")

func _process(delta: float) -> void:
	pass
