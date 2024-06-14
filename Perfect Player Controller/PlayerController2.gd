extends CharacterBody3D


const MAX_VERTICAL_LOOK_ANGLE: int = 89

const WALK_SPEED: float = 6.5

const AIR_ACCELERATION: float = 0.25
const GROUND_ACCELERATION: float = 1.0
const AIR_DECELERATION: float = 0.1
const GROUND_DECELERATION: float = 0.25


var mouse_sensitivity: float = 0.1

var jump_height: float = 1.25
var jump_time_to_peak: float = 0.3
var jump_time_to_descent: float = 0.3

var is_game_paused: bool = false


@onready var current_speed: float = WALK_SPEED

@onready var current_acceleration: float = GROUND_ACCELERATION
@onready var current_deceleration: float = GROUND_DECELERATION

@onready var jump_velocity: float = (2.0 * jump_height)/jump_time_to_peak
@onready var jump_gravity: float = (-2.0 * jump_height)/(jump_time_to_peak * jump_time_to_peak)
@onready var fall_gravity: float = (-2.0 * jump_height)/(jump_time_to_descent * jump_time_to_descent)

@onready var player_head: Node3D = $PlayerHead


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		player_head.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		player_head.rotation.x = clamp(player_head.rotation.x, deg_to_rad(-MAX_VERTICAL_LOOK_ANGLE), deg_to_rad(MAX_VERTICAL_LOOK_ANGLE))

func _unhandled_key_input(_event) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		pause_game() if !is_game_paused else unpause_game()
	
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = jump_velocity

func _physics_process(delta) -> void :
	var input_direction = Input.get_vector("MoveLeft", "MoveRight", "MoveForward", "MoveBackward")
	var move_direction = (transform.basis * Vector3(input_direction.x, 0 , input_direction.y)).normalized()
	
	if move_direction:
		velocity.x = lerp(velocity.x, move_direction.x * current_speed, delta * current_speed * current_acceleration)
		velocity.z = lerp(velocity.z, move_direction.z * current_speed, delta * current_speed * current_acceleration)
	else:
		velocity.x = lerp(velocity.x, 0.0, delta * current_speed * current_deceleration)
		velocity.z = lerp(velocity.z, 0.0, delta * current_speed * current_deceleration)
	
	player_gravity(delta)
	move_and_slide()

func player_gravity(delta : float) -> void:
	if is_on_floor():
		current_acceleration = GROUND_ACCELERATION
		current_deceleration = GROUND_DECELERATION
	else:
		current_acceleration = AIR_ACCELERATION
		current_deceleration = AIR_DECELERATION
		velocity.y += get_gravity() * delta

func get_gravity() -> float:
	return jump_gravity if velocity.y >= 0.0 else fall_gravity

func pause_game() -> void:
	is_game_paused = !is_game_paused
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func unpause_game() -> void:
	is_game_paused = !is_game_paused
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
