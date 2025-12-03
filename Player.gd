extends CharacterBody3D

const SPEED = 8.0
const JUMP_VELOCITY = 15.0 
const LANE_CHANGE_SPEED = 10.0
const GRAVITY = 30.0
const LANE_WIDTH = 5.0

const LANES = [-LANE_WIDTH, 0.0, LANE_WIDTH]
var current_lane_index = 1 
var target_x = LANES[1]
var is_sliding = false
var slide_timer = 0.0
const SLIDE_DURATION = 0.8

var max_health: int = 3
var current_health: int = max_health
signal player_died 

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var visuals_node: Node3D = $Visuals 

var standing_collision_shape: BoxShape3D

func _ready():
	if collision_shape and collision_shape.shape is BoxShape3D:
		standing_collision_shape = collision_shape.shape.duplicate()
	else:
		push_error("¡ERROR! Player.tscn debe tener un CollisionShape3D con un BoxShape3D.")
	
	_load_visual_character(preload("res://scenes/characters/character_k_2.tscn"))

func _load_visual_character(character_scene: Resource):
	for child in visuals_node.get_children():
		child.queue_free()
		
	var character_instance = character_scene.instantiate()
	visuals_node.add_child(character_instance)

func _physics_process(delta: float):
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
		
	var direction = Vector3(0, 0, -1) 
	velocity.z = direction.z * SPEED
	
	position.x = lerp(position.x, target_x, LANE_CHANGE_SPEED * delta)
	
	handle_input()
	handle_slide(delta)
	
	move_and_slide()



func take_damage():
	if current_health > 0:
		current_health -= 1
		print("¡Daño! Vida restante: ", current_health)
		
		if current_health <= 0:
			die()

func die():
	print("¡Game Over!")
	
	set_process(false) 
	set_physics_process(false)
	
	player_died.emit()
	

func handle_input():
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and not is_sliding: 
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_just_pressed("ui_right"): 
		change_lane(1) 
	elif Input.is_action_just_pressed("ui_left"): 
		change_lane(-1)
		
	if Input.is_action_just_pressed("ui_down") and is_on_floor() and not is_sliding: 
		start_slide()

func change_lane(direction: int):
	current_lane_index = clamp(current_lane_index + direction, 0, 2)
	target_x = LANES[current_lane_index]

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
