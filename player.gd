extends CharacterBody3D

var MouseSensitivity : float = 0.1
const MaxVerticalLookAngle : int = 90

var CurrentSpeed : float = 6.5

#Acceleration Deceleration
var CurrentAcceleration : float = 1.0
const AirAcceleration : float = 0.25
const GroundAcceleration : float = 1.0

var CurrentDeceleration : float = 0.75
const AirDeceleration : float = 0.1
const GroundDeceleration : float = 0.75

#Jump
var JumpHeight : float = 1.25
var JumpTimeToPeak : float = 0.3
var JumpTimeToDescent : float = 0.3

@onready var JumpVelocity : float = (2.0 * JumpHeight)/JumpTimeToPeak
@onready var JumpGravity : float = (-2.0 * JumpHeight)/(JumpTimeToPeak * JumpTimeToPeak)
@onready var FallGravity : float = (-2.0 * JumpHeight)/(JumpTimeToDescent * JumpTimeToDescent)

@onready var PlayerHead = $Head

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(deg_to_rad(-event.relative.x * MouseSensitivity))
		PlayerHead.rotate_x(deg_to_rad(-event.relative.y * MouseSensitivity))
		PlayerHead.rotation.x = clamp(PlayerHead.rotation.x, deg_to_rad(-MaxVerticalLookAngle), deg_to_rad(MaxVerticalLookAngle))
	
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JumpVelocity

func _physics_process(delta):
	var InputDirection = Input.get_vector("MoveLeft", "MoveRight", "MoveForward", "MoveBackward")
	var MoveDirection = (transform.basis * Vector3(InputDirection.x, 0, InputDirection.y)).normalized()
	if MoveDirection:
		velocity.x = lerp(velocity.x, MoveDirection.x * CurrentSpeed, delta * CurrentSpeed * CurrentAcceleration)
		velocity.z = lerp(velocity.z, MoveDirection.z * CurrentSpeed, delta * CurrentSpeed * CurrentAcceleration)
	else:
		velocity.x = lerp(velocity.x, 0.0, delta * CurrentSpeed * CurrentDeceleration)
		velocity.z = lerp(velocity.z, 0.0, delta * CurrentSpeed * CurrentDeceleration)
	print(InputDirection)
	Gravity(delta)
	move_and_slide()

func Gravity(delta : float):
	if is_on_floor():
		CurrentAcceleration = GroundAcceleration
		CurrentDeceleration = GroundDeceleration
	else:
		CurrentAcceleration = AirAcceleration
		CurrentDeceleration = AirDeceleration
		velocity.y += GetGravity() * delta

func GetGravity():
	return JumpGravity if velocity.y >= 0.0 else FallGravity
