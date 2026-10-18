extends Node

const PROJECTILE_LAUNCH_PATH := "res://assets/generated/audio/lm-projectile-launch-v1.wav"
const IMPACT_PATH := "res://assets/generated/audio/lm-impact-v1.wav"
const HEAL_PATH := "res://assets/generated/audio/lm-heal-v1.wav"
const CLUE_DISCOVERED_PATH := "res://assets/generated/audio/lm-clue-discovered-v1.wav"

func play_projectile_launch() -> void:
	_play_path(PROJECTILE_LAUNCH_PATH, -12.0)

func play_impact() -> void:
	_play_path(IMPACT_PATH, -10.0)

func play_heal() -> void:
	_play_path(HEAL_PATH, -14.0)

func play_clue_discovered() -> void:
	_play_path(CLUE_DISCOVERED_PATH, -9.0)

func _play_path(path: String, volume_db: float) -> void:
	var stream := load(path) as AudioStream
	if stream:
		_play(stream, volume_db)

func _play(stream: AudioStream, volume_db: float) -> void:
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = volume_db
	player.finished.connect(player.queue_free)
	add_child(player)
	player.play()

# Persistent BGM owner; existing SFX players remain independent.
const BGM_PATH := "res://assets/audio/bgm_main_loop.ogg"
var _bgm: AudioStreamPlayer
var _bgm_muted := false

func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventScreenTouch:
		if event.is_pressed():
			start_bgm()

func start_bgm() -> void:
	if not is_instance_valid(_bgm):
		var music := load(BGM_PATH) as AudioStreamOggVorbis
		if music == null:
			return
		music.loop = true
		_bgm = AudioStreamPlayer.new()
		_bgm.name = "BackgroundMusic"
		_bgm.stream = music
		_bgm.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(_bgm)
		set_bgm_muted(_bgm_muted)
	if not _bgm.playing:
		_bgm.play()

func set_bgm_muted(value: bool) -> void:
	_bgm_muted = value
	if is_instance_valid(_bgm):
		_bgm.volume_db = -80.0 if value else -12.0

func _notification(what: int) -> void:
	if is_instance_valid(_bgm):
		if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
			_bgm.stream_paused = true
		elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
			_bgm.stream_paused = false
