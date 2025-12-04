extends HBoxContainer


var max_health=3
var current_health=3
var heart_texture: Texture2D

func _ready():
	heart_texture= load("res://assets/art/pixel/pixil-frame-0.png")
	update_hearts()

func set_health(value:int):
	current_health=value
	update_hearts()

func set_max_health(value:int):
	max_health=value
	update_hearts()
	
func update_health(current, max):
	current_health = current
	max_health = max
	print("Actualizando vida: ", current_health, "/", max_health)
	update_hearts()

func update_hearts():
	for child in get_children():
		child.queue_free()
	for i in range(max_health):
		var heart = TextureRect.new()
		heart.texture= heart_texture
		heart.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		heart.modulate = Color(1,1,1,1) if i< current_health else Color(0.3,0.3,0.3,1)
		add_child(heart)
