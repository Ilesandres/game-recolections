extends CharacterBody3D

const BULLET_SPEED = 30.0
const DAMAGE_AMOUNT = 1 

var direction: Vector3 = Vector3.ZERO
var lifetime: float = 3.0 
var timer: float = 0.0

func set_velocity_and_direction(dir: Vector3):
	direction = dir
	velocity = direction * BULLET_SPEED


func _physics_process(delta: float):
	timer += delta
	if timer >= lifetime:
		queue_free()
		return

	move_and_slide()

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider.has_method("take_damage_from_bullet"):
			
			collider.take_damage_from_bullet(DAMAGE_AMOUNT)
			queue_free()
			return 
		
		var collider_layer = collider.get_collision_layer()
		if collider_layer & 2 or collider_layer & 5:
			queue_free()
			return
