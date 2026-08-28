extends Control

@onready var play_button: Button = %PlayButton
@onready var settings_button: Button = %SettingsButton
@onready var credits_button: Button = %CreditsButton
@onready var quit_button: Button = %QuitButton
@onready var best_time_label: Label = %BestTimeLabel

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	credits_button.pressed.connect(_on_credits_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	_update_best_time_display()

func _update_best_time_display() -> void:
	if GameManager.best_time < 999900.0:
		var mins = int(GameManager.best_time) / 60
		var secs = fmod(GameManager.best_time, 60.0)
		best_time_label.text = "MEJOR TIEMPO: %02d:%05.2f" % [mins, secs]
	else:
		best_time_label.text = "SIN RÉCORD AÚN"

func _on_play_pressed() -> void:
	GameManager.start_game()

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file(GameManager.SETTINGS_SCENE)

func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file(GameManager.CREDITS_SCENE)

func _on_quit_pressed() -> void:
	get_tree().quit()
