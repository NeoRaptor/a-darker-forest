extends Control

@onready var resume_button: Button = %ResumeButton
@onready var restart_button: Button = %RestartButton
@onready var settings_button: Button = %SettingsButton
@onready var menu_button: Button = %MenuButton

func _ready() -> void:
	visible = false
	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if GameManager.current_state == GameManager.GameState.PLAYING or GameManager.current_state == GameManager.GameState.PAUSED:
			toggle_pause()

func toggle_pause() -> void:
	var new_paused = !get_tree().paused
	get_tree().paused = new_paused
	visible = new_paused
	if new_paused:
		GameManager.current_state = GameManager.GameState.PAUSED
	else:
		GameManager.current_state = GameManager.GameState.PLAYING

func _on_resume_pressed() -> void:
	toggle_pause()

func _on_restart_pressed() -> void:
	get_tree().paused = false
	GameManager.restart_game()

func _on_settings_pressed() -> void:
	toggle_pause()
	get_tree().change_scene_to_file(GameManager.SETTINGS_SCENE)

func _on_menu_pressed() -> void:
	get_tree().paused = false
	GameManager.go_to_main_menu()
