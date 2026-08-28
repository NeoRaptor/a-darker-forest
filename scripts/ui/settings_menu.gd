extends Control

@onready var master_slider: HSlider = %MasterSlider
@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SFXSlider
@onready var fullscreen_check: CheckBox = %FullscreenCheck
@onready var back_button: Button = %BackButton

func _ready() -> void:
	master_slider.value = SettingsManager.master_volume
	music_slider.value = SettingsManager.music_volume
	sfx_slider.value = SettingsManager.sfx_volume
	fullscreen_check.button_pressed = SettingsManager.is_fullscreen

	master_slider.value_changed.connect(_on_master_changed)
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	back_button.pressed.connect(_on_back_pressed)

func _on_master_changed(value: float) -> void:
	SettingsManager.set_master_volume(value)

func _on_music_changed(value: float) -> void:
	SettingsManager.set_music_volume(value)

func _on_sfx_changed(value: float) -> void:
	SettingsManager.set_sfx_volume(value)

func _on_fullscreen_toggled(toggled_on: bool) -> void:
	SettingsManager.toggle_fullscreen(toggled_on)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(GameManager.MAIN_MENU_SCENE)
