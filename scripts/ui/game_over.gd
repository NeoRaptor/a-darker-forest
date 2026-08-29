extends Control

@onready var title_label: Label = %TitleLabel
@onready var time_stat_label: Label = %TimeStatLabel
@onready var cause_stat_label: Label = %CauseStatLabel
@onready var record_banner: Label = %RecordBanner
@onready var retry_button: Button = %RetryButton
@onready var menu_button: Button = %MenuButton

func _ready() -> void:
	visible = false
	retry_button.pressed.connect(_on_retry_pressed)
	menu_button.pressed.connect(_on_main_menu_pressed)

func show_results() -> void:
	visible = true
	_display_results()

func _display_results() -> void:
	if GameManager.player_hp <= 0:
		title_label.text = "YOU ARE DEAD..."
		title_label.add_theme_color_override("font_color", Color("e04545"))
		cause_stat_label.text = "CAUSE OF DEATH: %s" % GameManager.last_damage_source.capitalize()
	else:
		title_label.text = "Final: %s" % GameManager.evaluate_final_ending()
		title_label.add_theme_color_override("font_color", Color("4ae256"))
		cause_stat_label.text = "CAUSE OF DEATH: —"

	var mins = int(GameManager.elapsed_time) / 60
	var secs = fmod(GameManager.elapsed_time, 60.0)
	time_stat_label.text = "TIME SURVIVED: %02d:%05.2f" % [mins, secs]

	if GameManager.is_new_record:
		record_banner.visible = true
		record_banner.text = "★ NEW RECORD! ★"
	else:
		record_banner.visible = false

func _on_retry_pressed() -> void:
	get_tree().paused = false
	GameManager.start_game()

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	GameManager.go_to_main_menu()
