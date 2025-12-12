extends CharacterBody3D

const SPEED = 25.0 
const DAMAGE = 1    
const LIFETIME = 3.0
const GRAVITY = 0.0  

var direction: Vector3 = Vector3.FORWARD
var timer: float = 0.0

func _ready():
	set_process(true)
	pass

func set_velocity_and_direction(dir: Vector3):
	direction = dir.normalized()
	velocity = direction * SPEED

func _physics_process(delta):
	timer += delta
	if timer >= LIFETIME:
		queue_free()
		return
		
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		var collider = collision.get_collider()
		
		if collider and collider.has_method("take_damage_from_bullet"):
			collider.take_damage_from_bullet(DAMAGE)
			queue_free() 
			return
		
		queue_free()
		return
