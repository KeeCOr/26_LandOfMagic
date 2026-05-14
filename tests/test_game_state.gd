# tests/test_game_state.gd
extends GutTest

func before_each() -> void:
	GameState.xp = 0.0
	GameState.xp_to_next_level = 10.0
	GameState.level = 1
	GameState.castle_hp = 100.0
	GameState.castle_max_hp = 100.0

func test_gain_xp_triggers_level_up() -> void:
	var leveled_up = false
	GameState.level_up_triggered.connect(func(_c): leveled_up = true, CONNECT_ONE_SHOT)
	GameState.gain_xp(10.0)
	assert_true(leveled_up, "level_up_triggered should fire when XP threshold reached")
	assert_eq(GameState.level, 2)

func test_gain_xp_does_not_trigger_below_threshold() -> void:
	var leveled_up = false
	GameState.level_up_triggered.connect(func(_c): leveled_up = true, CONNECT_ONE_SHOT)
	GameState.gain_xp(5.0)
	assert_false(leveled_up, "level_up_triggered should not fire below threshold")
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
