# autoloads/GameState.gd
extends Node

const ClueConsequence = preload("res://scripts/clue_consequence.gd")

# 런 상태
var current_stage: int = 1
var current_wave: int = 0
var castle_hp: float = 100.0
var castle_max_hp: float = 100.0
var xp: float = 0.0
var xp_to_next_level: float = 10.0
var level: int = 1
var gold: int = 0

# 저택 탐색 상태
var current_room: String = "응접실"
var relationship: int = 50
var discovered_clues: Array[String] = []

# 슬롯 상태: [{unit_data: HeroData/FacilityData or null, unit_node: Node or null}]
var slot_count: int = 3
var slots: Array = []

# 선택지 풀
var hero_pool: Array[HeroData] = []
var facility_pool: Array[FacilityData] = []

signal level_up_triggered(choices: Array)
signal castle_died()
signal wave_cleared(wave_number: int)
signal stage_cleared(stage_number: int, gold_reward: int)
signal clue_discovered(result: Dictionary)
signal exploration_room_changed(room_name: String)

func _ready() -> void:
	SaveData.load_save()
	_apply_meta_upgrades()

func reset_run() -> void:
	current_wave = 0
	castle_hp = castle_max_hp
	xp = 0.0
	xp_to_next_level = 10.0
	level = 1
	gold = int(SaveData.get_upgrade_value("start_gold"))
	slots.clear()
	for i in slot_count:
		slots.append({unit_data = null, unit_node = null})

func reset_exploration() -> void:
	current_room = "응접실"
	relationship = 50
	discovered_clues.clear()

func discover_clue(clue_id: String, clue_name: String, relationship_delta: int, unlocked_room: String) -> Dictionary:
	if discovered_clues.has(clue_id):
		return {
			"already_discovered": true,
			"headline": "이미 확인한 단서",
			"relationship_delta": 0,
			"relationship_text": "관계 변화 없음",
			"next_choice": unlocked_room,
		}
	var consequence = ClueConsequence.build(clue_name, relationship_delta, unlocked_room)
	consequence["already_discovered"] = false
	discovered_clues.append(clue_id)
	relationship = clampi(relationship + relationship_delta, 0, 100)
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager:
		audio_manager.play_clue_discovered()
	emit_signal("clue_discovered", consequence)
	return consequence

func enter_exploration_room(room_name: String) -> void:
	current_room = room_name
	emit_signal("exploration_room_changed", room_name)

func gain_xp(amount: float) -> void:
	var bonus = 1.0 + SaveData.get_upgrade_value("xp_bonus") * 0.1
	xp += amount * bonus
	while xp >= xp_to_next_level:
		xp -= xp_to_next_level
		xp_to_next_level = floor(xp_to_next_level * 1.2)
		level += 1
		emit_signal("level_up_triggered", _get_levelup_choices())

func take_castle_damage(amount: float) -> void:
	castle_hp = max(0.0, castle_hp - amount)
	if castle_hp <= 0.0:
		emit_signal("castle_died")

func heal_castle(amount: float) -> void:
	castle_hp = min(castle_max_hp, castle_hp + amount)

func _get_levelup_choices() -> Array:
	var all: Array = []
	all.append_array(hero_pool)
	all.append_array(facility_pool)
	all.shuffle()
	return all.slice(0, 3)

func _apply_meta_upgrades() -> void:
	slot_count = 3 + int(SaveData.get_upgrade_value("slot_count"))
	castle_max_hp = 100.0 + SaveData.get_upgrade_value("max_hp") * 10.0
