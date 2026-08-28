extends Control

@onready var title_label: Label = %TitleLabel
@onready var time_stat_label: Label = %TimeStatLabel
@onready var orbs_stat_label: Label = %OrbsStatLabel
@onready var record_banner: Label = %RecordBanner
@onready var retry_button: Button = %RetryButton
@onready var menu_button: Button = %MenuButton

func _ready() -> void:
	retry_button.pressed.connect(_on_retry_pressed)
	menu_button.pressed.connect(_on_main_menu_pressed)
	
	_display_results()

func _display_results() -> void:
	var final_ending = GameManager.evaluate_final_ending()
	
	if GameManager.player_hp <= 0:
		title_label.text = "NOTICIA DE ÚLTIMA HORA:\n'Cazador no sobrevivió al bosque'"
		title_label.add_theme_color_override("font_color", Color("e04545"))
	else:
		title_label.text = "NOTICIA DE ÚLTIMA HORA:\nFinal: %s" % final_ending
		title_label.add_theme_color_override("font_color", Color("4ae256"))

	var mins = int(GameManager.elapsed_time) / 60
	var secs = fmod(GameManager.elapsed_time, 60.0)
	time_stat_label.text = "TIEMPO EN EL BOSQUE: %02d:%05.2f" % [mins, secs]
	orbs_stat_label.text = "VIDA RESTANTE: %d / %d" % [GameManager.player_hp, GameManager.max_hp]
	
	if GameManager.is_new_record:
		record_banner.visible = true
		record_banner.text = "★ ¡NUEVO RÉCORD DE SUPERVIVENCIA! ★"
	else:
		record_banner.visible = false

func _on_retry_pressed() -> void:
	GameManager.start_game()

func _on_main_menu_pressed() -> void:
	GameManager.go_to_main_menu()
