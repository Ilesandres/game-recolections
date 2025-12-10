extends CharacterBody3D

const SPEED = 8.0
const JUMP_VELOCITY = 15.0
const GRAVITY = 30.0
const DAMAGE_ANIMATION_TIME = 0.5 

const CAMERA_SMOOTH_SPEED = 5.0
const ROTATION_SMOOTH_SPEED = 10.0 

var is_sliding = false
var slide_timer = 0.0
const SLIDE_DURATION = 0.8

var max_health: int = 3
var current_health: int = max_health
signal player_died
var is_taking_damage: bool = false 

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var visuals_node: Node3D = $Visuals
@onready var animation_timer: Timer = $AnimationTimer
@onready var camera_boom: Node3D = $CameraBoom 

signal health_changed(current_health, max_health)

var animation_player: AnimationPlayer = null

var standing_collision_shape: BoxShape3D

func _ready():
	if collision_shape and collision_shape.shape is BoxShape3D:
		standing_collision_shape = collision_shape.shape.duplicate()
	else:
		push_error("¡ERROR! Player.tscn debe tener un CollisionShape3D con un BoxShape3D.")
	
	_load_visual_character(load(GlobalData.selected_character_scene_path))
	
	animation_timer.timeout.connect(_on_animation_timer_timeout)

	emit_signal("health_changed", current_health, max_health)
	global_position.y=0.5


func _load_visual_character(character_scene: Resource):
	for child in visuals_node.get_children():
		child.queue_free()
		
	var character_instance = character_scene.instantiate()
	visuals_node.add_child(character_instance)
	
	animation_player = character_instance.get_node("AnimationPlayer")
	if animation_player:
		animation_player.animation_finished.connect(_on_animation_finished)
	else:
		print("Advertencia: El personaje cargado no tiene un AnimationPlayer.")


func _physics_process(delta: float):
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	var input_dir = Vector3.ZERO
	if Input.is_action_pressed("ui_right"):
		input_dir.x -= 1
	if Input.is_action_pressed("ui_left"):
		input_dir.x += 1
	if Input.is_action_pressed("ui_front"):
		input_dir.z += 1
	if Input.is_action_pressed("ui_back"):
		input_dir.z -= 1

	input_dir = input_dir.normalized()

	if not is_taking_damage:
		
		var movement_vector = Vector3.ZERO
		
		if input_dir != Vector3.ZERO:
			var basis = visuals_node.global_transform.basis
			
			movement_vector = basis * input_dir
			
			movement_vector.y = 0 
			movement_vector = movement_vector.normalized()
			
			velocity.x = movement_vector.x * SPEED
			velocity.z = movement_vector.z * SPEED
			
			var target_transform = visuals_node.global_transform.looking_at(
				global_position + movement_vector, 
				Vector3.UP, 
				true
			)
			
			visuals_node.global_transform.basis = visuals_node.global_transform.basis.slerp(
				target_transform.basis, 
				delta * ROTATION_SMOOTH_SPEED
			)
			
			if not is_sliding:
				play_animation("walk")
		
		elif is_on_floor():
			velocity.x = 0.0
			velocity.z = 0.0
			if not is_sliding:
				if animation_player and animation_player.has_animation("idle"):
					play_animation("idle")
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
	move_and_slide()


func take_damage():
	if current_health > 0:
		current_health -= 1
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
	
	play_animation("die")
	
	animation_timer.stop() 

func _on_animation_finished(anim_name):
	if(anim_name == "die"):
		set_process(false)
		set_physics_process(false)
		player_died.emit()
	

func handle_jump_and_slide():
	if is_taking_damage or is_sliding:
		return

	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_pressed("ui_down") and is_on_floor() and not is_sliding:
		start_slide()


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
		play_animation("sprint")
