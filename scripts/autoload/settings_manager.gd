extends Node

# Settings Manager Autoload
# Handles audio volumes, screen mode, and game configuration

signal volume_changed(bus_name: String, value: float)
signal fullscreen_changed(is_fullscreen: bool)

var master_volume: float = 0.8
var music_volume: float = 0.7
var sfx_volume: float = 0.9
var is_fullscreen: bool = false

func _ready() -> void:
	# Ensure audio buses exist or fallback safely
	_apply_all_settings()

func set_master_volume(value: float) -> void:
	master_volume = clamp(value, 0.0, 1.0)
	_set_bus_volume("Master", master_volume)
	volume_changed.emit("Master", master_volume)

func set_music_volume(value: float) -> void:
	music_volume = clamp(value, 0.0, 1.0)
	_set_bus_volume("Music", music_volume)
	volume_changed.emit("Music", music_volume)

func set_sfx_volume(value: float) -> void:
	sfx_volume = clamp(value, 0.0, 1.0)
	_set_bus_volume("SFX", sfx_volume)
	volume_changed.emit("SFX", sfx_volume)

func toggle_fullscreen(enable: bool) -> void:
	is_fullscreen = enable
	if is_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	fullscreen_changed.emit(is_fullscreen)

func _set_bus_volume(bus_name: String, linear_val: float) -> void:
	var bus_idx = AudioServer.get_bus_index(bus_name)
	if bus_idx != -1:
		var db_val = linear_to_db(linear_val) if linear_val > 0.0001 else -80.0
		AudioServer.set_bus_volume_db(bus_idx, db_val)

func _apply_all_settings() -> void:
	_set_bus_volume("Master", master_volume)
	_set_bus_volume("Music", music_volume)
	_set_bus_volume("SFX", sfx_volume)
