extends CharacterBody3D

const SPEED = 5.0
const DAMAGE = 1 
const MIN_DISTANCE_TO_PLAYER = 0.5 
const MAX_STEP_HEIGHT = 0.41 
const OBSTACLE_PREFIX = "driveway-long"

@onready var player: CharacterBody3D = get_tree().get_first_node_in_group("player")
@onready var ground_ray: RayCast3D = $GroundRay 
@onready var step_ray: RayCast3D = $StepRay     

const MOB_GRAVITY = 20.0 
const ROTATION_SPEED = 10.0

func _ready():
	if player == null:
		print("Advertencia: El jugador no se encontró en el grupo 'player'.")
	
	if is_instance_valid(ground_ray):
		ground_ray.add_exception(self)
	if is_instance_valid(step_ray):
		step_ray.add_exception(self)


func _physics_process(delta: float):
	if not is_on_floor():
		velocity.y -= MOB_GRAVITY * delta
	else:
		velocity.y = 0.0

	if not is_instance_valid(player):
		velocity = Vector3.ZERO
		move_and_slide()
		return

	var to_player = player.global_position - global_position
	
	var flat_to_player = to_player
	flat_to_player.y = 0
	var dist = flat_to_player.length()
	
	var direction = Vector3.ZERO
	if dist > MIN_DISTANCE_TO_PLAYER:
		direction = flat_to_player.normalized()
		
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		var target_angle = atan2(direction.x, direction.z)
		
		rotation.y = lerp_angle(rotation.y, target_angle, delta * ROTATION_SPEED)
	else:
		velocity.x = 0.0
		velocity.z = 0.0
		
	if direction.length_squared() > 0.01:
		_handle_step_climb()

	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider.has_method("take_damage"):
			collider.take_damage()
			queue_free()
			return

func _handle_step_climb():
	if not is_instance_valid(ground_ray) or not is_instance_valid(step_ray):
		print("Mob: Advertencia: Los RayCasts no están correctamente configurados.")
		return

	
	step_ray.force_raycast_update()
	
	if step_ray.is_colliding():
		var collider = step_ray.get_collider()
		print("Mob: Colisión detectada con: ", collider.name)
		
		if not collider.name.to_lower().begins_with(OBSTACLE_PREFIX): 
			print("Mob: El collider no es un obstáculo válido: ", collider.name)
			if not (is_instance_valid(collider.get_parent()) and collider.get_parent().name.to_lower().begins_with(OBSTACLE_PREFIX)):
				print("Mob: El padre del collider tampoco es un obstáculo válido: ", collider.get_parent().name)
				return
			 
		var hit_point = step_ray.get_collision_point()
		var step_height = hit_point.y - global_position.y
		
		if step_height >= MAX_STEP_HEIGHT:
			print("Mob: Obstáculo demasiado alto para escalar: ", step_height)
			return
		ground_ray.global_position = hit_point
		ground_ray.global_position.y += MAX_STEP_HEIGHT + 0.05 
		
		ground_ray.target_position = Vector3(0, -(MAX_STEP_HEIGHT + 0.1), 0)
		
		ground_ray.force_raycast_update()
		
		if ground_ray.is_colliding():
			var ground_point = ground_ray.get_collision_point()
			print("Mob: Punto de suelo detectado en: ", ground_point)
			
			global_position.y = ground_point.y + (global_transform.basis.y.y * 0.01)
			
			
			velocity.y = 1.0 
