extends Node2D

# Level 1 Controller (Un Bosque Oscuro)
# Handles parallax scrolling, GDD UI HUD updating, and input shortcuts.

@onready var hp_label: Label = %HPLabel
@onready var log_label: Label = %LogLabel
@onready var shotgun_label: Label = %ShotgunLabel
@onready var kerosene_label: Label = %KeroseneLabel
@onready var camera_label: Label = %CameraLabel
@onready var shout_label: Label = %ShoutLabel
@onready var pause_menu: Control = %PauseMenu

func _ready() -> void:
	GameManager.hp_changed.connect(_update_hud_display)
	GameManager.resources_changed.connect(_update_hud_display)
	GameManager.log_message_posted.connect(update_log_text)
	_update_hud_display()

func _unhandled_input(event: InputEvent) -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return
	if not (event is InputEventKey and event.pressed and not event.echo):
		return

	match event.keycode:
		KEY_1:
			_report_resource_use(GameManager.use_bullet(), "Preparas la escopeta.", "No te quedan balas.")
		KEY_2:
			_report_resource_use(GameManager.use_kerosene(), "Enciendes la antorcha.", "Te quedaste sin kerosene.")
		KEY_3:
			_report_resource_use(GameManager.use_film(), "Tomas una fotografía.", "No te queda película.")
		KEY_4:
			_report_resource_use(GameManager.try_shout(), "\"¡Hola!?\" — tu voz se pierde entre los árboles.", "Necesitas esperar antes de volver a gritar.")

func _report_resource_use(success: bool, success_text: String, fail_text: String) -> void:
	update_log_text(success_text if success else fail_text)

func _update_hud_display(_arg = null) -> void:
	# Update HP Hearts
	var hearts = ""
	for i in range(GameManager.player_hp):
		hearts += "♥ "
	hp_label.text = hearts.strip_edges()

	# Update Resources
	shotgun_label.text = "[1] Escopeta: %d" % GameManager.bullets
	kerosene_label.text = "[2] Kerosene: %d" % GameManager.kerosene
	camera_label.text = "[3] Cámara: %d" % GameManager.film_rolls
	shout_label.text = "[4] Gritar (Listo)" if GameManager.is_shout_ready() else "[4] Gritar (Enfriando)"

func update_log_text(text: String) -> void:
	if log_label:
		log_label.text = text
