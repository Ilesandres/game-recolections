extends CharacterBody3D

const SPEED_NORMAL = 8.0
const SPEED_MEDIUM = 10.0
const SPEED_FAST = 12.0
const SPEED_MAX = 30
const JUMP_VELOCITY = 15.0
const GRAVITY = 30.0
const DAMAGE_ANIMATION_TIME = 0.5

const CAMERA_SMOOTH_SPEED = 5.0
const ROTATION_SMOOTH_SPEED = 10.0

const MAX_STEP_HEIGHT = 0.41
const OBSTACLE_PREFIX = "driveway-long"

const IDLE_ARMED_ANIMATION = "static_weapon"
const IDLE_UNARMED_ANIMATION = "static-weapon"

const SPRINT_SPEED = 14.0
const SPRINT_JUMP_VELOCITY = 20.0

const SHOOT_COOLDOWN = 0.2
const AUTO_FIRE_COOLDOWN = 0.01

var SHOOT_SOUND_PATH = "res://assets/audio/weapons/shoots/shoot-arma-blaster-a.mp3"
var DEATH_SOUND_PATH = "res://assets/audio/dead-player.mp3"

var shoot_timer: float = 0.0
var bullet_scene = null
var muzzle_node: Node3D = null

var use_cooldown := true

var is_fire_button_held: bool = false

var mouse_rotation_delta_x := 0.0
var mouse_sensitivity := 0.015

var is_sliding = false
var slide_timer = 0.0
const SLIDE_DURATION = 0.8

var max_health: int = 5
var current_health: int = max_health
signal player_died
var is_taking_damage: bool = false
var is_shooting: bool = false

const POWER_3_COOLDOWN = 5.0
var character_power_1: String = ""
var character_power_2: String = ""
var character_power_3: String = ""
var power_3_timer: float = 0.0
var current_base_speed: float = SPEED_NORMAL

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var visuals_node: Node3D = $Visuals
@onready var animation_timer: Timer = $AnimationTimer
@onready var camera_boom: Node3D = $CameraBoom
@onready var auto_jump_ray: RayCast3D = $AutoJumpRay
@onready var ground_ray: RayCast3D = $GroundRay

@onready var shoot_sound_player: AudioStreamPlayer3D = $ShootSoundPlayer
@onready var death_sound_player: AudioStreamPlayer3D = $DeathSoundPlayer

signal health_changed(current_health, max_health)
signal  reload_cooldown()

var animation_player: AnimationPlayer = null
var current_weapon: Node3D = null

var standing_collision_shape: BoxShape3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	current_health= GlobalData.character_health
	max_health= GlobalData.character_health
	SHOOT_SOUND_PATH=GlobalData.weapon_sound_shoot_path
	
	character_power_1=GlobalData.character_power_1
	character_power_2=GlobalData.character_power_2
	character_power_3=GlobalData.character_power_3
	power_3_timer=0.0
	
	match character_power_2:
		"nomalSpeed":
			current_base_speed = SPRINT_SPEED
		"MediunSpeed":
			current_base_speed = SPEED_MEDIUM
		"FastSpeed":
			current_base_speed = SPEED_FAST
		"MaxSpeed":
			current_base_speed = SPEED_MAX

	use_cooldown = GlobalData.weapon_cooldown

	if collision_shape and collision_shape.shape is BoxShape3D:
		standing_collision_shape = collision_shape.shape.duplicate()
	else:
		push_error("¡ERROR! Player.tscn debe tener un CollisionShape3D con un BoxShape3D.")

	_load_visual_character(load(GlobalData.selected_character_scene_path))

	_load_weapon()

	animation_timer.timeout.connect(_on_animation_timer_timeout)

	emit_signal("health_changed", current_health, max_health)
	global_position.y=0.5

	if is_instance_valid(ground_ray):
		ground_ray.add_exception(self)
	if is_instance_valid(auto_jump_ray):
		auto_jump_ray.add_exception(self)

	if not GlobalData.selected_bullet_scene_path.is_empty():
		bullet_scene = load(GlobalData.selected_bullet_scene_path)
		if bullet_scene == null:
			push_error("Error al cargar la escena de la bala: " + GlobalData.selected_bullet_scene_path)
			
	_load_audio_stream(shoot_sound_player, SHOOT_SOUND_PATH)
	_load_audio_stream(death_sound_player, DEATH_SOUND_PATH)

func _load_audio_stream(player: AudioStreamPlayer3D, path: String):
	if ResourceLoader.exists(path):
		player.stream = load(path)
	else:
		push_error("ERROR: No se encontró el archivo de sonido para " + player.name + " en: " + path)

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		mouse_rotation_delta_x += -event.relative.x * mouse_sensitivity

	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
				
				if not use_cooldown:
					if event.pressed:
						is_fire_button_held = true
						shoot()
					else:
						is_fire_button_held = false
				
				else:
					if event.pressed:
						shoot()
						
	if Input.is_action_just_pressed("shoot"):
		shoot()
		
	if Input.is_action_just_pressed("power1"):
		activate_power_3()

	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			print("Mouse liberado (Modo Pausa/Menú).")
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			print("Mouse capturado (Modo Juego).")


func _load_visual_character(character_scene: Resource):
	for child in visuals_node.get_children():
		child.queue_free()
		
	var character_instance = character_scene.instantiate()
	visuals_node.add_child(character_instance)
	
	animation_player = character_instance.get_node("AnimationPlayer")
	if animation_player:
		animation_player.animation_finished.connect(_on_animation_finished)
		if current_weapon == null:
			play_animation(IDLE_UNARMED_ANIMATION)
		else:
			pass
	else:
		print("Advertencia: El personaje cargado no tiene un AnimationPlayer.")


func _load_weapon():
	var weapon_path = GlobalData.selected_weapon_scene_path
	if not ResourceLoader.exists(weapon_path):
		print("Advertencia: La ruta del arma no existe: ", weapon_path)
		return

	var weapon_scene = load(weapon_path)
	if not weapon_scene:
		print("Advertencia: No se pudo cargar el recurso del arma.")
		return
		
	if current_weapon and is_instance_valid(current_weapon):
		current_weapon.queue_free()
		current_weapon = null
		
	current_weapon = weapon_scene.instantiate()
	
	var character_instance: Node = visuals_node.get_children().front()
	
	if not is_instance_valid(character_instance):
		print("Advertencia: No se encontró la instancia del personaje para adjuntar el arma.")
		current_weapon.queue_free()
		current_weapon = null
		return
		
	var hand_node: Node3D = character_instance.find_child("Hand_R", true, false)

	if hand_node:
		hand_node.add_child(current_weapon)
		print("Arma '", current_weapon.name, "' cargada y adjuntada a Hand_R.")
		
		muzzle_node = current_weapon.find_child("Muzzle", true, false)
		if muzzle_node == null:
			print("Advertencia: No se encontró el nodo 'Muzzle' en el arma. Usando la posición del arma como origen.")
			muzzle_node = current_weapon
			
	else:
		character_instance.add_child(current_weapon)
		print("Advertencia: Nodo de agarre 'Hand_R' NO encontrado. Arma adjuntada a la raíz del personaje.")
		muzzle_node = current_weapon

	if current_weapon != null and animation_player:
		play_animation(IDLE_ARMED_ANIMATION)
		
		shoot_timer = SHOOT_COOLDOWN
		
func _process(delta: float):
	if shoot_timer > 0.0:
		shoot_timer -= delta
		
	if power_3_timer > 0.0:
		power_3_timer -= delta
		
	if not use_cooldown:
		if is_fire_button_held and shoot_timer <= 0.0:
			shoot()
			shoot_timer = AUTO_FIRE_COOLDOWN

func shoot():
	print("Intentando disparar. Cooldown activado:", use_cooldown)

	if is_taking_damage or is_sliding or is_shooting:
		print("No se puede disparar ahora.")
		return
	
	if use_cooldown and shoot_timer > 0.0:
		print("No se puede disparar ahora (Cooldown activo).")
		return

	if bullet_scene and muzzle_node:
		if not is_instance_valid(muzzle_node) or not muzzle_node.is_inside_tree():
			print("Advertencia: No se pudo disparar. El punto de salida (Muzzle) no es válido o no está en el árbol.")
			return
			
		if shoot_sound_player.stream:
			shoot_sound_player.play()

		print("Disparando bala desde: ", muzzle_node.global_position)

		var num_bullets = 1
		var spread_angle = 0.0
		
		match character_power_1:
			"ShootTwo":
				num_bullets = 2
				spread_angle = 0.15
			"ShootThree":
				num_bullets = 3
				spread_angle = 0.25
			"ShootFour":
				num_bullets = 4
				spread_angle = 0.40
		
		var base_transform = global_transform.basis
		var game_root = get_tree().get_root().find_child("Game", true, false)
		var instance_root = game_root if game_root else get_tree().get_root()
		
		for i in range(num_bullets):
			var new_bullet = bullet_scene.instantiate()
			instance_root.add_child(new_bullet)

			new_bullet.global_position = muzzle_node.global_position

			if "attacker" in new_bullet:
				new_bullet.attacker = self

			var current_spread = 0.0
			if num_bullets > 1:
				current_spread = remap(float(i), 0.0, float(num_bullets - 1), -spread_angle, spread_angle)

			var rotated_direction = base_transform.rotated(Vector3.UP, current_spread).z.normalized() * -1.0

			if new_bullet.has_method("set_velocity_and_direction"):
				new_bullet.set_velocity_and_direction(rotated_direction)
			else:
				push_error("Bullet scene does not have 'set_velocity_and_direction' method.")


		play_animation("holding-right-shoot")
		is_shooting = true

		if use_cooldown:
			shoot_timer = SHOOT_COOLDOWN
		else:
			shoot_timer = AUTO_FIRE_COOLDOWN

	elif bullet_scene == null:
		print("Advertencia: No se pudo disparar, la escena de la bala no está cargada.")
	elif muzzle_node == null:
		print("Advertencia: No se pudo disparar, el punto de salida (Muzzle) no fue encontrado.")



func _physics_process(delta: float):
	rotate_y(mouse_rotation_delta_x)
	mouse_rotation_delta_x = 0.0

	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	var input_dir = Vector3.ZERO
	if Input.is_action_pressed("ui_right"):
		input_dir.x += 1
	if Input.is_action_pressed("ui_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("ui_front"):
		input_dir.z -= 1
	if Input.is_action_pressed("ui_back"):
		input_dir.z += 1

	input_dir = input_dir.normalized()

	var movement_vector = Vector3.ZERO

	var idle_anim = IDLE_UNARMED_ANIMATION
	if is_instance_valid(current_weapon):
		idle_anim = IDLE_ARMED_ANIMATION

	var is_sprinting = Input.is_action_pressed("sprint") and input_dir.length_squared() > 0.01
	var current_speed = current_base_speed if is_sprinting else SPEED_NORMAL

	if not is_taking_damage:
		if input_dir != Vector3.ZERO:
			var basis = global_transform.basis
			movement_vector = basis * input_dir
			movement_vector.y = 0
			movement_vector = movement_vector.normalized()

			velocity.x = movement_vector.x * current_speed
			velocity.z = movement_vector.z * current_speed

			if not is_sliding:
				if not is_shooting:
					if is_sprinting:
						play_animation("sprint")
					else:
						play_animation("walk")

		elif is_on_floor():
			velocity.x = 0.0
			velocity.z = 0.0
			if not is_sliding:
				if not is_shooting:
					if animation_player and animation_player.has_animation(idle_anim):
						play_animation(idle_anim)
	else:
		velocity.x = 0.0
		velocity.z = 0.0

	var visual_back_direction = -visuals_node.global_transform.basis.z.normalized()
	var camera_offset = Vector3(0, 2, 6)
	var target_camera_position = global_position
	target_camera_position += visual_back_direction * camera_offset.z
	target_camera_position.y += camera_offset.y
	camera_boom.global_position = camera_boom.global_position.lerp(
		target_camera_position,
		delta * CAMERA_SMOOTH_SPEED
	)
	camera_boom.look_at(global_position, Vector3.UP)

	handle_jump_and_slide()
	handle_slide(delta)

	if not is_taking_damage and not is_sliding:
		_handle_auto_step_climb(movement_vector)

	move_and_slide()
	
func handle_jump_and_slide():
	if is_taking_damage or is_sliding:
		return
	
	var is_sprinting = Input.is_action_pressed("sprint")

	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		if is_sprinting:
			velocity.y = SPRINT_JUMP_VELOCITY
		else:
			velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_pressed("ui_down") and is_on_floor() and not is_sliding:
		start_slide()


func take_damage(amount: int = 1):
	if current_health > 0:
		current_health -= amount
		print("¡Daño! Vida restante: ", current_health)
		
		is_taking_damage = true
		play_animation("emote-no")
		emit_signal("health_changed", current_health, max_health)
		animation_timer.start(DAMAGE_ANIMATION_TIME)
		
		if current_health <= 0:
			emit_signal("health_changed", current_health, max_health)
			die()

func die():
	print("¡Game Over!")
	
	if death_sound_player.stream:
		death_sound_player.play()
	
	play_animation("die")
	
	animation_timer.stop()

func _on_animation_finished(anim_name):
	if(anim_name == "die"):
		if Input.get_mouse_mode()== Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		set_process(false)
		set_physics_process(false)
		player_died.emit()
	
	if(anim_name == "holding-right-shoot"):
		is_shooting = false
		
		var next_idle_anim = IDLE_UNARMED_ANIMATION
		if is_instance_valid(current_weapon):
			next_idle_anim = IDLE_ARMED_ANIMATION
			
		
		if velocity.length_squared() > 0.1 and is_on_floor():
			if Input.is_action_pressed("sprint"):
				play_animation("sprint")
			else:
				play_animation("walk")
		elif is_on_floor():
			play_animation(next_idle_anim)
	

func start_slide():
	is_sliding = true
	slide_timer = 0.0
	
	if collision_shape.shape is BoxShape3D:
		var original_extents: Vector3 = standing_collision_shape.extents
		var slide_height = original_extents.y / 2.0
		var slide_center = -original_extents.y / 2.0
		
		var slide_shape: BoxShape3D = standing_collision_shape.duplicate()
		slide_shape.extents = Vector3(original_extents.x, slide_height, original_extents.z)
		collision_shape.shape = slide_shape
		collision_shape.position.y = slide_center
		
		play_animation("slide")


func play_animation(anim_name: String):
	if animation_player and animation_player.has_animation(anim_name):
		animation_player.play(anim_name)
	else:
		print("Advertencia no se encontro la animacion '", anim_name, "' para el personaje o el AnimationPlayer es nulo.")


func handle_slide(delta: float):
	if is_sliding:
		slide_timer += delta
		if slide_timer >= SLIDE_DURATION:
			end_slide()

func end_slide():
	is_sliding = false
	if standing_collision_shape:
		collision_shape.shape = standing_collision_shape
		collision_shape.position.y = 0.0
		
		play_animation("sprint")

func _on_animation_timer_timeout():
	if not is_sliding and current_health > 0:
		is_taking_damage = false
		var idle_anim = IDLE_UNARMED_ANIMATION
		if is_instance_valid(current_weapon):
			idle_anim = IDLE_ARMED_ANIMATION
			
		if velocity.length_squared() < 0.1:
			play_animation(idle_anim)


func _handle_auto_step_climb(direction: Vector3):
	if not is_on_floor() or direction.length_squared() < 0.01:
		return
	
	if not is_instance_valid(ground_ray) or not is_instance_valid(auto_jump_ray):
		return

	auto_jump_ray.force_raycast_update()
	
	if auto_jump_ray.is_colliding():
		print("Player: AutoJumpRay colisionó con: ", auto_jump_ray.get_collider().name)
		var collider = auto_jump_ray.get_collider()
		
		var is_correct_obstacle = false
		if is_instance_valid(collider):
			print("Player: Verificando si el collider es un obstáculo válido: ", collider.name)
			if collider.name.to_lower().begins_with(OBSTACLE_PREFIX):
				is_correct_obstacle = true
			elif is_instance_valid(collider.get_parent()) and collider.get_parent().name.to_lower().begins_with(OBSTACLE_PREFIX):
				is_correct_obstacle = true
		
		if not is_correct_obstacle:
			print("Player: El collider no es un obstáculo válido para escalar: ", collider.name)
			return
			
		var hit_point = auto_jump_ray.get_collision_point()
		var step_height = hit_point.y - global_position.y
		
		if step_height >= MAX_STEP_HEIGHT:
			return
		
		ground_ray.global_position = hit_point
		ground_ray.global_position.y += MAX_STEP_HEIGHT + 0.05
		
		ground_ray.target_position = Vector3(0, -(MAX_STEP_HEIGHT + 0.2), 0)
		
		ground_ray.force_raycast_update()
		
		if ground_ray.is_colliding():
			
			var jump_val = JUMP_VELOCITY * 0.5
			if Input.is_action_pressed("sprint"):
				jump_val = SPRINT_JUMP_VELOCITY * 0.5
				
			velocity.y = jump_val
			
			var move_speed = current_base_speed
			if Input.is_action_pressed("sprint"):
				move_speed = SPRINT_SPEED
				
			velocity.x = direction.x * move_speed
			velocity.z = direction.z * move_speed


func activate_power_3():
	if character_power_3 != "Shunpo":
		return
		
	if power_3_timer > 0.0:
		print("Power 3 (Shunpo) en cooldown: ", power_3_timer, "s restantes.")
		return
	
	if is_taking_damage or is_sliding:
		return

	var move_direction = -global_transform.basis.z.normalized()
	var dash_distance = 8.0
	
	var ray_check = RayCast3D.new()
	add_child(ray_check)
	ray_check.target_position = move_direction * dash_distance
	ray_check.force_raycast_update()
	
	var target_position = global_position
	
	if ray_check.is_colliding():
		var hit_point = ray_check.get_collision_point()
		target_position = hit_point + move_direction * 0.5
	else:
		target_position = global_position + move_direction * dash_distance

	ray_check.queue_free()
	
	global_position = target_position
	
	print("¡Shunpo Activado! Teletransportado a: ", global_position)
	emit_signal("reload_cooldown")
	
	power_3_timer = POWER_3_COOLDOWN
	

func on_mob_killed():
	print("Jugador notificó que un mob fue eliminado.")
	if character_power_3 != "saqueo":
		print("El jugador no tiene el poder de saqueo.")
		return
	print("El jugador tiene el poder de saqueo, intentando activar efecto.")

	if current_health < max_health:
		var chance = 0.25
		if randf() < chance:
			current_health = min(current_health + 1, max_health)
			emit_signal("health_changed", current_health, max_health)
			print("¡Saqueo exitoso! Vida recuperada. Vida actual: ", current_health)

func try_life_steal():
	on_mob_killed()
