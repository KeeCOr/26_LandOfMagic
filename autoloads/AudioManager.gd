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
