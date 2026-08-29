extends CharacterBody2D

# Hunter Controller (Lateral Movement, Bullet-time support, Camera & Visibility)

@export var move_speed: float = 45.0
@export var gravity: float = 600.0

## Escala de la máscara de visión en reposo (1.0 = tamaño base del gradiente).
@export var vision_scale_normal: float = 1.0
## Multiplicador de la máscara mientras la antorcha está encendida (1.2 = +20%).
@export var vision_torch_multiplier: float = 1.2
## Opacidad del borde oscuro de la máscara (0 = invisible, 1 = negro total).
@export_range(0.0, 1.0) var vision_mask_opacity: float = 0.92
## Duración del tween al agrandar/achicar la máscara al usar la antorcha.
@export var vision_tween_duration: float = 0.4
## Cuánto dura encendida la antorcha (también su cooldown antes de poder usarla de nuevo).
@export var torch_duration: float = 4.0
## Duración de cada mitad del flash de cámara (apagado + encendido).
@export var camera_flash_duration: float = 0.1

var speed_multiplier: float = 1.0 # Modified during bullet-time encounters
var is_in_encounter: bool = false

@onready var camera: Camera2D = %Camera2D
@onready var hunter_sprite: AnimatedSprite2D = %HunterSprite
@onready var vision_mask: Sprite2D = %VisionMask
@onready var torch_ignite_sound: AudioStreamPlayer = %TorchIgniteSound

func _ready() -> void:
	hunter_sprite.play("idle")
	vision_mask.scale = Vector2.ONE * vision_scale_normal
	vision_mask.modulate.a = vision_mask_opacity
	GameManager.kerosene_cooldown_duration = torch_duration
	GameManager.kerosene_used.connect(_on_kerosene_used)
	GameManager.film_used.connect(_on_film_used)

func _on_kerosene_used() -> void:
	var normal_scale := Vector2.ONE * vision_scale_normal
	var torch_scale := normal_scale * vision_torch_multiplier

	var grow_tween := create_tween()
	grow_tween.tween_property(vision_mask, "scale", torch_scale, vision_tween_duration)

	if torch_ignite_sound and torch_ignite_sound.stream:
		torch_ignite_sound.play()

	await get_tree().create_timer(GameManager.kerosene_cooldown_duration).timeout

	var shrink_tween := create_tween()
	shrink_tween.tween_property(vision_mask, "scale", normal_scale, vision_tween_duration)

func _on_film_used() -> void:
	var flash_tween := create_tween()
	flash_tween.tween_property(vision_mask, "modulate:a", 0.0, camera_flash_duration)
	flash_tween.tween_property(vision_mask, "modulate:a", vision_mask_opacity, camera_flash_duration)

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
		hunter_sprite.flip_h = input_dir < 0
		if hunter_sprite.animation != "walk":
			hunter_sprite.play("walk")
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed * 10.0 * delta)
		if hunter_sprite.animation != "idle":
			hunter_sprite.play("idle")

	move_and_slide()

# Set bullet time deceleration ratio (e.g. 0.25 during encounter)
func set_bullet_time(active: bool, multiplier: float = 0.3) -> void:
	is_in_encounter = active
	speed_multiplier = multiplier if active else 1.0
