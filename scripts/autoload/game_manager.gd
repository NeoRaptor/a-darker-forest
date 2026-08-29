extends Node

# Game Manager Autoload (Un Bosque Oscuro)
# Manages gameplay state, resources, marbles bag, and karma/ending evaluation.

signal hp_changed(current_hp: int)
signal resources_changed()
signal log_message_posted(text: String)
signal game_over_triggered(ending_type: String)
signal kerosene_used()
signal film_used()
signal bullet_used()
signal shout_used()
signal heartbeat_changed(active: bool)

enum GameState { MENU, PLAYING, PAUSED, ENCOUNTER, GAME_OVER }

var current_state: GameState = GameState.MENU

# Player Resources (GDD Section 6)
var player_hp: int = 4
var max_hp: int = 4
var last_damage_source: String = ""
var bullets: int = 4
var kerosene: int = 5
var film_rolls: int = 3

# Stats & High Replayability
var elapsed_time: float = 0.0
var best_time: float = 999999.0
var is_new_record: bool = false
var distance_traversed: float = 0.0

# Karma Tracking (GDD Section 8)
var violence_shots: int = 0
var innocent_kills: int = 0
var threats_neutralized: int = 0
var social_helps: int = 0
var social_ignores: int = 0
var witness_survivors: int = 0

# Shout cooldown (GDD 4.5: costo natural del grito, no consume stock)
const SHOUT_COOLDOWN_SECONDS: float = 2.0
var shout_cooldown_remaining: float = 0.0

# Cooldowns por recurso: evitan gastar todo de una y alimentan las barras del HUD.
# La antorcha usa su cooldown como duración de efecto (visión ampliada mientras dura).
# kerosene_cooldown_duration no es const: Player la sobreescribe con su valor
# exportado (@export torch_duration) al arrancar, para poder ajustarla desde el Inspector.
const SHOTGUN_COOLDOWN_SECONDS: float = 1.0
var kerosene_cooldown_duration: float = 4.0
const CAMERA_COOLDOWN_SECONDS: float = 1.5
var shotgun_cooldown_remaining: float = 0.0
var kerosene_cooldown_remaining: float = 0.0
var camera_cooldown_remaining: float = 0.0

const MAIN_MENU_SCENE: String = "res://scenes/ui/main_menu.tscn"
const LEVEL_1_SCENE: String = "res://scenes/game/level_1.tscn"
const SETTINGS_SCENE: String = "res://scenes/ui/settings_menu.tscn"
const CREDITS_SCENE: String = "res://scenes/ui/credits_menu.tscn"

# Sonidos que no dependen de una escena en particular (HP, muerte): se crean a mano
# porque este autoload es un script suelto, sin nodo de escena propio donde ponerlos.
var _hurt_sound: AudioStreamPlayer
var _death_sound: AudioStreamPlayer
var _heartbeat_sound: AudioStreamPlayer
var _near_death_drone: AudioStreamPlayer
var _near_death_drone_timer: Timer

# Cuánto tarda en sumarse el drone de tensión después de que arranca el latido (HP crítico).
const NEAR_DEATH_DRONE_DELAY: float = 15.0

func _ready() -> void:
	# Sin esto, get_tree().paused=true (game over) corta en seco cualquier sonido
	# que dependa de este autoload, incluido el de muerte que se dispara justo antes de pausar.
	process_mode = Node.PROCESS_MODE_ALWAYS
	# GDD 4.1 pide input A/D; ui_left/ui_right vienen mapeados solo a flechas por defecto.
	_bind_key_if_missing("ui_left", KEY_A)
	_bind_key_if_missing("ui_right", KEY_D)
	_hurt_sound = _make_sound_player("res://assets/audio/player_hurt_sfx.mp3")
	_death_sound = _make_sound_player("res://assets/audio/player_death_sfx.mp3")
	_heartbeat_sound = _make_sound_player("res://assets/audio/heart_beating_near_death.mp3")
	_near_death_drone = _make_sound_player("res://assets/audio/ambient_drone_ending_loop.mp3", "Music")
	_near_death_drone_timer = Timer.new()
	_near_death_drone_timer.one_shot = true
	_near_death_drone_timer.wait_time = NEAR_DEATH_DRONE_DELAY
	_near_death_drone_timer.timeout.connect(_on_near_death_drone_timeout)
	add_child(_near_death_drone_timer)

func _make_sound_player(stream_path: String, bus: String = "SFX") -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.stream = load(stream_path)
	player.bus = bus
	add_child(player)
	return player

func _on_near_death_drone_timeout() -> void:
	if player_hp == 1:
		_near_death_drone.play()

func _bind_key_if_missing(action: String, keycode: Key) -> void:
	for event in InputMap.action_get_events(action):
		if event is InputEventKey and event.keycode == keycode:
			return
	var key_event := InputEventKey.new()
	key_event.keycode = keycode
	InputMap.action_add_event(action, key_event)

func _process(delta: float) -> void:
	if current_state == GameState.PLAYING:
		elapsed_time += delta
	if shout_cooldown_remaining > 0.0:
		shout_cooldown_remaining = max(0.0, shout_cooldown_remaining - delta)
		if shout_cooldown_remaining == 0.0:
			resources_changed.emit()
	shotgun_cooldown_remaining = max(0.0, shotgun_cooldown_remaining - delta)
	kerosene_cooldown_remaining = max(0.0, kerosene_cooldown_remaining - delta)
	camera_cooldown_remaining = max(0.0, camera_cooldown_remaining - delta)

func start_game() -> void:
	elapsed_time = 0.0
	distance_traversed = 0.0
	player_hp = max_hp
	last_damage_source = ""
	bullets = 4
	kerosene = 5
	film_rolls = 3
	shout_cooldown_remaining = 0.0
	shotgun_cooldown_remaining = 0.0
	kerosene_cooldown_remaining = 0.0
	camera_cooldown_remaining = 0.0
	violence_shots = 0
	innocent_kills = 0
	threats_neutralized = 0
	social_helps = 0
	social_ignores = 0
	witness_survivors = 0
	is_new_record = false
	current_state = GameState.PLAYING
	if _heartbeat_sound:
		_heartbeat_sound.stop()
		_near_death_drone.stop()
		_near_death_drone_timer.stop()
	get_tree().paused = false
	get_tree().change_scene_to_file(LEVEL_1_SCENE)

func restart_game() -> void:
	start_game()

func take_damage(amount: int, source: String = "una herida desconocida") -> void:
	last_damage_source = source
	player_hp = max(0, player_hp - amount)
	hp_changed.emit(player_hp)
	if player_hp <= 0:
		_heartbeat_sound.stop()
		_near_death_drone.stop()
		_near_death_drone_timer.stop()
		heartbeat_changed.emit(false)
		_death_sound.play()
		trigger_game_over("muerto")
	else:
		_hurt_sound.play()
		if player_hp <= 1:
			if not _heartbeat_sound.playing:
				_heartbeat_sound.play()
				_near_death_drone_timer.start()
				heartbeat_changed.emit(true)
		else:
			_heartbeat_sound.stop()
			_near_death_drone.stop()
			_near_death_drone_timer.stop()
			heartbeat_changed.emit(false)

# Resource consumption (GDD 4.5 / 6). Returns false when el recurso está agotado
# o todavía en cooldown (evita que el jugador desperdicie todo de una).
func use_bullet() -> bool:
	if bullets <= 0 or shotgun_cooldown_remaining > 0.0:
		return false
	bullets -= 1
	shotgun_cooldown_remaining = SHOTGUN_COOLDOWN_SECONDS
	resources_changed.emit()
	bullet_used.emit()
	return true

func use_kerosene() -> bool:
	if kerosene <= 0 or kerosene_cooldown_remaining > 0.0:
		return false
	kerosene -= 1
	kerosene_cooldown_remaining = kerosene_cooldown_duration
	resources_changed.emit()
	kerosene_used.emit()
	return true

func use_film() -> bool:
	if film_rolls <= 0 or camera_cooldown_remaining > 0.0:
		return false
	film_rolls -= 1
	camera_cooldown_remaining = CAMERA_COOLDOWN_SECONDS
	resources_changed.emit()
	film_used.emit()
	return true

func try_shout() -> bool:
	if shout_cooldown_remaining > 0.0:
		return false
	shout_cooldown_remaining = SHOUT_COOLDOWN_SECONDS
	resources_changed.emit()
	shout_used.emit()
	return true

func is_shout_ready() -> bool:
	return shout_cooldown_remaining <= 0.0

func is_bullet_ready() -> bool:
	return shotgun_cooldown_remaining <= 0.0

func is_kerosene_ready() -> bool:
	return kerosene_cooldown_remaining <= 0.0

func is_camera_ready() -> bool:
	return camera_cooldown_remaining <= 0.0

func get_shotgun_cooldown_fraction() -> float:
	return shotgun_cooldown_remaining / SHOTGUN_COOLDOWN_SECONDS

func get_kerosene_cooldown_fraction() -> float:
	return kerosene_cooldown_remaining / kerosene_cooldown_duration

func get_camera_cooldown_fraction() -> float:
	return camera_cooldown_remaining / CAMERA_COOLDOWN_SECONDS

func trigger_game_over(ending_reason: String) -> void:
	if current_state == GameState.GAME_OVER:
		return
	
	current_state = GameState.GAME_OVER
	if elapsed_time < best_time and ending_reason != "muerto":
		best_time = elapsed_time
		is_new_record = true

	get_tree().paused = true
	game_over_triggered.emit(ending_reason)

func evaluate_final_ending() -> String:
	# Ending logic based on GDD Section 8
	if innocent_kills > 0 and witness_survivors > 0:
		return "Condenado a prisión"
	elif innocent_kills > 0 or (violence_shots >= 3 and social_ignores >= 3):
		return "Psicópata"
	elif threats_neutralized >= 2 and social_helps >= 1:
		return "Héroe nacional"
	else:
		return "Caminante perdido"

func go_to_main_menu() -> void:
	current_state = GameState.MENU
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
