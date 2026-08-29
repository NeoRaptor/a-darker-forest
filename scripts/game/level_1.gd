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

func _ready() -> void:
	_apply_ground_surface_y()
	GameManager.hp_changed.connect(_update_hud_display)
	GameManager.resources_changed.connect(_update_hud_display)
	GameManager.log_message_posted.connect(update_log_text)
	shotgun_usar_button.pressed.connect(_use_shotgun)
	kerosene_usar_button.pressed.connect(_use_kerosene)
	camera_usar_button.pressed.connect(_use_camera)
	_update_hud_display()

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
