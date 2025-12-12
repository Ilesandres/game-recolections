
extends CharacterBody3D

const SPEED = 5.0
const DAMAGE = 1 

@onready var player: CharacterBody3D = get_tree().get_first_node_in_group("player")

func _ready():
	if player == null:
		print("Advertencia: El jugador no se encontró en el grupo 'player'.")

func _physics_process(delta: float):
	if is_instance_valid(player):
		var direction = (player.global_position - global_position).normalized()
		direction.y = 0 
		
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		if direction.length() > 0.01:
			look_at(player.global_position, Vector3.UP, true)

		move_and_slide()
	else:
		velocity = Vector3.ZERO
		move_and_slide()

func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage()
		
		queue_free()
