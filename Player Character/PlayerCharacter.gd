extends CharacterBody3D


const MAX_VERTICAL_LOOK_ANGLE: int = 89

const WALK_SPEED: float = 7.5

const AIR_ACCELERATION: float = 0.25
const GROUND_ACCELERATION: float = 0.5
const AIR_DECELERATION: float = 0.1
const GROUND_DECELERATION: float = 1.0

const JUMP_HEIGHT: float = 1.25
const JUMP_TIME_TO_PEAK: float = 0.3
const JUMP_TIME_TO_DESCENT: float = 0.3


var mouse_sensitivity: float = 0.1

var input_direction: Vector2 = Vector2.ZERO
var move_direction: Vector3 = Vector3.ZERO


@onready var current_speed: float = WALK_SPEED
@onready var current_acceleration: float = GROUND_ACCELERATION
@onready var current_deceleration: float = GROUND_DECELERATION

@onready var jump_velocity: float = (2.0 * JUMP_HEIGHT)/JUMP_TIME_TO_PEAK
@onready var jump_gravity: float = (-2.0 * JUMP_HEIGHT)/(JUMP_TIME_TO_PEAK * JUMP_TIME_TO_PEAK)
@onready var fall_gravity: float = (-2.0 * JUMP_HEIGHT)/(JUMP_TIME_TO_DESCENT * JUMP_TIME_TO_DESCENT)

@onready var player_head: Node3D = $PlayerHead


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		player_head.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		player_head.rotation.x = clamp(player_head.rotation.x, deg_to_rad(-MAX_VERTICAL_LOOK_ANGLE), deg_to_rad(MAX_VERTICAL_LOOK_ANGLE))
	
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity


func _physics_process(delta: float) -> void:
	input_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	move_direction = (transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	
	if move_direction:
		velocity.x = lerp(velocity.x, move_direction.x * current_speed, delta * current_speed * current_acceleration)
		velocity.z = lerp(velocity.z, move_direction.z * current_speed, delta * current_speed * current_acceleration)
	else:
		velocity.x = lerp(velocity.x, 0.0, delta * current_speed * current_deceleration)
		velocity.z = lerp(velocity.z, 0.0, delta * current_speed * current_deceleration)
	
	player_gravity(delta)
	move_and_slide()


func player_gravity(delta: float) -> void:
	if is_on_floor():
		current_acceleration = GROUND_ACCELERATION
		current_deceleration = GROUND_DECELERATION
	else:
		current_acceleration = AIR_ACCELERATION
		current_deceleration = AIR_DECELERATION
		velocity.y += get_player_gravity() * delta


func get_player_gravity() -> float:
	return jump_gravity if velocity.y >= 0.0 else fall_gravity
