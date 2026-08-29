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
## Qué tan fuerte sacude la cámara al disparar la escopeta (en píxeles).
@export var shotgun_shake_strength: float = 3.0
## Cuánto dura la sacudida de la cámara al disparar.
@export var shotgun_shake_duration: float = 0.2
## Arrastrá acá los clips de paso (se elige uno al azar en cada paso).
@export var footstep_sounds: Array[AudioStream] = []
## Segundos entre un paso y el siguiente mientras camina.
@export var footstep_interval: float = 0.55

var speed_multiplier: float = 1.0 # Modified during bullet-time encounters
var is_in_encounter: bool = false
var shake_time_remaining: float = 0.0
var footstep_timer: float = 0.0
var last_footstep_index: int = -1

@onready var camera: Camera2D = %Camera2D
@onready var hunter_sprite: AnimatedSprite2D = %HunterSprite
@onready var vision_mask: Sprite2D = %VisionMask
@onready var torch_ignite_sound: AudioStreamPlayer = %TorchIgniteSound
@onready var footstep_sound: AudioStreamPlayer = %FootstepSound
@onready var camera_flash_sound: AudioStreamPlayer = %CameraFlashSound
@onready var shout_sound: AudioStreamPlayer = %ShoutSound
@onready var shotgun_sound: AudioStreamPlayer = %ShotgunSound

func _ready() -> void:
	hunter_sprite.play("idle")
	vision_mask.scale = Vector2.ONE * vision_scale_normal
	vision_mask.modulate.a = vision_mask_opacity
	GameManager.kerosene_cooldown_duration = torch_duration
	GameManager.kerosene_used.connect(_on_kerosene_used)
	GameManager.film_used.connect(_on_film_used)
	GameManager.bullet_used.connect(_on_bullet_used)
	GameManager.shout_used.connect(_on_shout_used)

func _process(delta: float) -> void:
	if shake_time_remaining > 0.0:
		shake_time_remaining -= delta
		if shake_time_remaining > 0.0:
			camera.offset = Vector2(
				randf_range(-shotgun_shake_strength, shotgun_shake_strength),
				randf_range(-shotgun_shake_strength, shotgun_shake_strength)
			)
		else:
			camera.offset = Vector2.ZERO

func _on_bullet_used() -> void:
	shake_time_remaining = shotgun_shake_duration
	if shotgun_sound and shotgun_sound.stream:
		shotgun_sound.play()

func _on_shout_used() -> void:
	if shout_sound and shout_sound.stream:
		shout_sound.play()

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
	if camera_flash_sound and camera_flash_sound.stream:
		camera_flash_sound.play()
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
		_process_footsteps(delta)
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed * 10.0 * delta)
		if hunter_sprite.animation != "idle":
			hunter_sprite.play("idle")
		footstep_timer = 0.0

	move_and_slide()

func _process_footsteps(delta: float) -> void:
	if footstep_sounds.is_empty() or not is_on_floor():
		return
	footstep_timer -= delta
	if footstep_timer <= 0.0:
		footstep_timer = footstep_interval
		var index := randi() % footstep_sounds.size()
		if index == last_footstep_index:
			index = (index + 1) % footstep_sounds.size()
		last_footstep_index = index
		footstep_sound.stream = footstep_sounds[index]
		footstep_sound.play()

# Set bullet time deceleration ratio (e.g. 0.25 during encounter)
func set_bullet_time(active: bool, multiplier: float = 0.3) -> void:
	is_in_encounter = active
	speed_multiplier = multiplier if active else 1.0
