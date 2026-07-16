# tests/test_game_state.gd
extends GutTest

var _level_up_count := 0

func before_each() -> void:
	_level_up_count = 0
	GameState.xp = 0.0
	GameState.xp_to_next_level = 10.0
	GameState.level = 1
	GameState.castle_hp = 100.0
	GameState.castle_max_hp = 100.0

func _record_level_up(_choices: Array) -> void:
	_level_up_count += 1

func test_gain_xp_triggers_level_up() -> void:
	GameState.level_up_triggered.connect(_record_level_up)
	GameState.gain_xp(10.0)
	GameState.level_up_triggered.disconnect(_record_level_up)
	assert_eq(_level_up_count, 1, "level_up_triggered should fire when XP threshold reached")
	assert_eq(GameState.level, 2)

func test_gain_xp_can_trigger_multiple_level_ups_from_large_reward() -> void:
	GameState.level_up_triggered.connect(_record_level_up)
	GameState.gain_xp(25.0)
	GameState.level_up_triggered.disconnect(_record_level_up)
	assert_eq(GameState.level, 3)
	assert_eq(_level_up_count, 2)
	assert_eq(GameState.xp, 3.0)
	assert_eq(GameState.xp_to_next_level, 14.0)

func test_gain_xp_does_not_trigger_below_threshold() -> void:
	GameState.level_up_triggered.connect(_record_level_up)
	GameState.gain_xp(5.0)
	GameState.level_up_triggered.disconnect(_record_level_up)
	assert_eq(_level_up_count, 0, "level_up_triggered should not fire below threshold")
	assert_eq(GameState.level, 1)

func test_take_castle_damage_clamps_to_zero() -> void:
	GameState.castle_hp = 10.0
	GameState.take_castle_damage(999.0)
	assert_eq(GameState.castle_hp, 0.0)

func test_heal_castle_clamps_to_max() -> void:
	GameState.castle_max_hp = 100.0
	GameState.castle_hp = 90.0
	GameState.heal_castle(50.0)
	assert_eq(GameState.castle_hp, 100.0)

func test_reset_run_initializes_slots() -> void:
	GameState.slot_count = 3
	GameState.reset_run()
	assert_eq(GameState.slots.size(), 3)
	for slot in GameState.slots:
		assert_null(slot.unit_data)
