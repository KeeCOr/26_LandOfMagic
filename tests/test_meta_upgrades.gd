# tests/test_meta_upgrades.gd
extends GutTest

func before_each() -> void:
	SaveData.meta_upgrades = {}
	SaveData.total_gold = 500

func test_upgrade_succeeds_with_enough_gold() -> void:
	var result = SaveData.try_upgrade("slot_count", 150, 3)
	assert_true(result)
	assert_eq(SaveData.get_upgrade_level("slot_count"), 1)
	assert_eq(SaveData.total_gold, 350)

func test_upgrade_fails_without_gold() -> void:
	SaveData.total_gold = 50
	var result = SaveData.try_upgrade("slot_count", 150, 3)
	assert_false(result)
	assert_eq(SaveData.get_upgrade_level("slot_count"), 0)

func test_upgrade_fails_at_max_level() -> void:
	SaveData.meta_upgrades["slot_count"] = 3
	var result = SaveData.try_upgrade("slot_count", 150, 3)
	assert_false(result)

func test_get_upgrade_value_returns_zero_for_unset() -> void:
	assert_eq(SaveData.get_upgrade_value("nonexistent"), 0.0)
