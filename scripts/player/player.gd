extends CharacterBody2D

# Hunter Controller (Lateral Movement, Bullet-time support, Camera & Visibility)

@export var move_speed: float = 75.0
@export var gravity: float = 600.0

var speed_multiplier: float = 1.0 # Modified during bullet-time encounters
var is_in_encounter: bool = false

@onready var eyes_light: PointLight2D = %EyesLight
@onready var torch_light: PointLight2D = %TorchLight
@onready var camera: Camera2D = %Camera2D
@onready var hunter_sprite: ColorRect = %HunterSprite

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Lateral Input (A/D or Left/Right)
	var input_dir := Input.get_axis("ui_left", "ui_right")
	
	# Current effective speed affected by bullet-time slow-motion
	var current_speed = move_speed * speed_multiplier
	
	if input_dir != 0:
		velocity.x = input_dir * current_speed
		# Flip sprite/light direction slightly
		if input_dir > 0:
			hunter_sprite.position.x = -4
			eyes_light.position.x = 2
		elif input_dir < 0:
			hunter_sprite.position.x = -4
			eyes_light.position.x = -2
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed * 10.0 * delta)

	move_and_slide()

# Set bullet time deceleration ratio (e.g. 0.25 during encounter)
func set_bullet_time(active: bool, multiplier: float = 0.3) -> void:
	is_in_encounter = active
	speed_multiplier = multiplier if active else 1.0
