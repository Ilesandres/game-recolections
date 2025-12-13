extends CharacterBody3D

const SPEED = 5.0
const DAMAGE = 1 
const MIN_DISTANCE_TO_PLAYER = 0.5 
const MAX_STEP_HEIGHT = 0.41 
const OBSTACLE_PREFIX = "driveway-long"

@onready var player: CharacterBody3D = get_tree().get_first_node_in_group("player")
@onready var ground_ray: RayCast3D = $GroundRay 
@onready var step_ray: RayCast3D = $StepRay
@onready var animation_player: AnimationPlayer = $"character-n2"/AnimationPlayer 
var is_dying: bool = false

const MOB_GRAVITY = 20.0 
const ROTATION_SPEED = 10.0

var max_health: int = 1
var current_health: int = max_health


func _ready():
	if player == null:
		print("Advertencia: El jugador no se encontró en el grupo 'player'.")
	
	if is_instance_valid(ground_ray):
		ground_ray.add_exception(self)
	if is_instance_valid(step_ray):
		step_ray.add_exception(self)
	
	if animation_player == null:
		print("Mob: Advertencia: AnimationPlayer no encontrado en 'character-n2'.")
	else:
		animation_player.animation_finished.connect(_on_animation_finished)
	
	max_health = 5 + (GlobalData.current_level * 2) 
	current_health = max_health
	print("Mob creado. Nivel: ", GlobalData.current_level, " | Vida: ", current_health)


func play_mob_animation(anim_name: String):
	if is_dying:
		return
		
	if animation_player and animation_player.has_animation(anim_name) and animation_player.current_animation != anim_name:
		animation_player.play(anim_name)
	elif animation_player == null:
		return
	elif not animation_player.has_animation(anim_name):
		print("Mob: Advertencia: No se encontró la animación '", anim_name, "'.")

func take_damage_from_bullet(amount: int):
	if current_health <= 0 or is_dying:
		return
		
	current_health -= amount
	print("Mob golpeado, vida restante: ", current_health)
	
	play_mob_animation("hit")
	
	if current_health <= 0:
		die()
		
func die():
	if is_dying:
		return
		
	is_dying = true
	print("Mob destruido. Puntos: +10")
	GlobalData.add_score(10) 
	print("Puntaje actual: ", GlobalData.current_score)
	
	if animation_player and animation_player.has_animation("die"):
		animation_player.play("die")
	else:
		queue_free()


func _on_animation_finished(anim_name: String):
	if anim_name == "die":
		queue_free()
	
	elif anim_name == "hit":
		if current_health > 0:
			pass 

func _physics_process(delta: float):
	if is_dying:
		velocity = Vector3.ZERO
		move_and_slide()
		return
		
	if not is_on_floor():
		velocity.y -= MOB_GRAVITY * delta
	else:
		velocity.y = 0.0

	if not is_instance_valid(player):
		velocity = Vector3.ZERO
		move_and_slide()
		play_mob_animation("idle") 
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
		
		
		play_mob_animation("walk")
	else:
		velocity.x = 0.0
		velocity.z = 0.0
		
		play_mob_animation("idle")
		
	if direction.length_squared() > 0.01:
		_handle_step_climb()

	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider.has_method("take_damage"):
			play_mob_animation("attack-melee-right")
			print("Mob ataca al jugador, infligiendo ", DAMAGE, " de daño.")
			collider.take_damage()
			return

func _handle_step_climb():
	if not is_instance_valid(ground_ray) or not is_instance_valid(step_ray):
		print("Mob: Advertencia: Los RayCasts no están correctamente configurados.")
		return

	step_ray.force_raycast_update()
	
	if step_ray.is_colliding():
		var collider = step_ray.get_collider()
		
		var is_correct_obstacle = false
		if collider.name.to_lower().begins_with(OBSTACLE_PREFIX): 
			is_correct_obstacle = true
		elif is_instance_valid(collider.get_parent()) and collider.get_parent().name.to_lower().begins_with(OBSTACLE_PREFIX):
			is_correct_obstacle = true
		
		if not is_correct_obstacle:
			return
			
		var hit_point = step_ray.get_collision_point()
		var step_height = hit_point.y - global_position.y
		
		if step_height >= MAX_STEP_HEIGHT:
			return
			
		ground_ray.global_position = hit_point
		ground_ray.global_position.y += MAX_STEP_HEIGHT + 0.05
		ground_ray.target_position = Vector3(0, -(MAX_STEP_HEIGHT + 0.1), 0)
		
		ground_ray.force_raycast_update()
		
		if ground_ray.is_colliding():
			var ground_point = ground_ray.get_collision_point()
			
			global_position.y = ground_point.y + (global_transform.basis.y.y * 0.01)
			velocity.y = 1.0
