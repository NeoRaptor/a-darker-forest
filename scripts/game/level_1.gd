extends Node2D

# Level 1 Controller (Un Bosque Oscuro)
# Handles parallax scrolling, GDD UI HUD updating, and input shortcuts.

## Altura (Y) de la superficie del suelo. Mueve este valor y dale Play para
## ver el resultado: la plataforma y el jugador se reposicionan juntos.
@export var ground_surface_y: float = 180.0

@onready var forest_path: StaticBody2D = $Environment/ForestPath
@onready var ground_collision: CollisionShape2D = $Environment/ForestPath/CollisionShape2D
@onready var player: CharacterBody2D = $Player

@onready var heart_1: TextureRect = %Heart1
@onready var heart_2: TextureRect = %Heart2
@onready var heart_3: TextureRect = %Heart3
@onready var log_label: Label = %LogLabel
@onready var shotgun_label: Label = %ShotgunLabel
@onready var kerosene_label: Label = %KeroseneLabel
@onready var camera_label: Label = %CameraLabel
@onready var shotgun_usar_button: Button = %ShotgunUsarButton
@onready var kerosene_usar_button: Button = %KeroseneUsarButton
@onready var camera_usar_button: Button = %CameraUsarButton
@onready var shotgun_cooldown_bar: ProgressBar = %ShotgunCooldownBar
@onready var kerosene_cooldown_bar: ProgressBar = %KeroseneCooldownBar
@onready var camera_cooldown_bar: ProgressBar = %CameraCooldownBar
@onready var pause_menu: Control = %PauseMenu
@onready var game_over_overlay: Control = %GameOverOverlay

@onready var packing_sound: AudioStreamPlayer = %PackingSound
@onready var random_detail_sound: AudioStreamPlayer = %RandomDetailSound
@onready var random_detail_timer: Timer = %RandomDetailTimer

@onready var heart_pulse_icon: TextureRect = %HeartPulse

## Separación entre los dos golpes seguidos del latido (lub-dub).
@export var heart_beat_gap: float = 0.15
## Pausa antes de repetir el par de golpes. Ajustá ambos para calzar con el audio.
@export var heart_beat_pause: float = 0.85

var _heartbeat_active: bool = false

# Detalles ambientales sueltos que se solapan al loop base de tanto en tanto
# (no son loops en sí, son variaciones puntuales para que el fondo no se sienta estático).
const RANDOM_DETAIL_SOUNDS: Array[AudioStream] = [
	preload("res://assets/audio/random_sfx_creek.mp3"),
	preload("res://assets/audio/random_sfx_drone.mp3"),
	preload("res://assets/audio/random_sfx_wind.mp3"),
]
const RANDOM_DETAIL_MIN_INTERVAL: float = 25.0
const RANDOM_DETAIL_MAX_INTERVAL: float = 60.0

func _ready() -> void:
	_apply_ground_surface_y()
	GameManager.hp_changed.connect(_update_hud_display)
	GameManager.resources_changed.connect(_update_hud_display)
	GameManager.log_message_posted.connect(update_log_text)
	shotgun_usar_button.pressed.connect(_use_shotgun)
	kerosene_usar_button.pressed.connect(_use_kerosene)
	camera_usar_button.pressed.connect(_use_camera)
	random_detail_timer.timeout.connect(_on_random_detail_timeout)
	GameManager.game_over_triggered.connect(_on_game_over_triggered)
	GameManager.heartbeat_changed.connect(_on_heartbeat_changed)
	_update_hud_display()
	packing_sound.play()
	_schedule_next_random_detail()

func _on_game_over_triggered(_ending_reason: String) -> void:
	game_over_overlay.show_results()

func _on_heartbeat_changed(active: bool) -> void:
	_heartbeat_active = active
	if active:
		_run_heart_pulse_loop()

func _run_heart_pulse_loop() -> void:
	while _heartbeat_active:
		_pulse_heart_icon()
		await get_tree().create_timer(heart_beat_gap).timeout
		if not _heartbeat_active:
			break
		_pulse_heart_icon()
		await get_tree().create_timer(heart_beat_pause).timeout

func _pulse_heart_icon() -> void:
	var tween := create_tween()
	tween.tween_property(heart_pulse_icon, "scale", Vector2(1.3, 1.3), 0.08)
	tween.tween_property(heart_pulse_icon, "scale", Vector2(1.0, 1.0), 0.12)

func _on_random_detail_timeout() -> void:
	random_detail_sound.stream = RANDOM_DETAIL_SOUNDS[randi() % RANDOM_DETAIL_SOUNDS.size()]
	random_detail_sound.play()
	_schedule_next_random_detail()

func _schedule_next_random_detail() -> void:
	random_detail_timer.wait_time = randf_range(RANDOM_DETAIL_MIN_INTERVAL, RANDOM_DETAIL_MAX_INTERVAL)
	random_detail_timer.start()

func _unhandled_input(event: InputEvent) -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return
	if not (event is InputEventKey and event.pressed and not event.echo):
		return

	match event.keycode:
		KEY_1:
			_use_shotgun()
		KEY_2:
			_use_kerosene()
		KEY_3:
			_use_camera()
		KEY_SPACE:
			_report_resource_use(GameManager.try_shout(), "\"¡Hola!?\" — tu voz se pierde entre los árboles.", "Necesitas esperar antes de volver a gritar.")
		KEY_0:
			# DEBUG: quita 1 corazón para probar sonidos de daño/muerte/latido sin encuentros reales.
			GameManager.take_damage(1, "una herida de prueba (tecla 0)")
			update_log_text("[DEBUG] Recibes daño de prueba.")

func _use_shotgun() -> void:
	if GameManager.bullets <= 0:
		update_log_text("No te quedan balas.")
	elif not GameManager.is_bullet_ready():
		update_log_text("La escopeta todavía se está recargando.")
	else:
		GameManager.use_bullet()
		update_log_text("Preparas la escopeta.")

func _use_kerosene() -> void:
	if GameManager.kerosene <= 0:
		update_log_text("Te quedaste sin kerosene.")
	elif not GameManager.is_kerosene_ready():
		update_log_text("La antorcha todavía está encendida.")
	else:
		GameManager.use_kerosene()
		update_log_text("Enciendes la antorcha.")

func _use_camera() -> void:
	if GameManager.film_rolls <= 0:
		update_log_text("No te queda película.")
	elif not GameManager.is_camera_ready():
		update_log_text("La cámara todavía se está recargando.")
	else:
		GameManager.use_film()
		update_log_text("Tomas una fotografía.")

func _report_resource_use(success: bool, success_text: String, fail_text: String) -> void:
	update_log_text(success_text if success else fail_text)

func _process(_delta: float) -> void:
	shotgun_cooldown_bar.value = GameManager.get_shotgun_cooldown_fraction()
	kerosene_cooldown_bar.value = GameManager.get_kerosene_cooldown_fraction()
	camera_cooldown_bar.value = GameManager.get_camera_cooldown_fraction()
	shotgun_usar_button.disabled = GameManager.bullets <= 0 or not GameManager.is_bullet_ready()
	kerosene_usar_button.disabled = GameManager.kerosene <= 0 or not GameManager.is_kerosene_ready()
	camera_usar_button.disabled = GameManager.film_rolls <= 0 or not GameManager.is_camera_ready()

func _apply_ground_surface_y() -> void:
	var shape := ground_collision.shape as RectangleShape2D
	var half_height := shape.size.y / 2.0
	forest_path.position.y = ground_surface_y + half_height
	player.position.y = ground_surface_y

func _update_hud_display(_arg = null) -> void:
	# Update HP hearts (el pulso siempre visible; los contornos desaparecen con el daño)
	heart_1.visible = GameManager.player_hp >= 2
	heart_2.visible = GameManager.player_hp >= 3
	heart_3.visible = GameManager.player_hp >= 4

	# Update Resources
	shotgun_label.text = "x %d" % GameManager.bullets
	kerosene_label.text = "x %d" % GameManager.kerosene
	camera_label.text = "x %d" % GameManager.film_rolls

func update_log_text(text: String) -> void:
	if log_label:
		log_label.text = text
