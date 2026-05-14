# autoloads/SaveData.gd
extends Node

const SAVE_PATH = "user://lm_save.json"

var meta_upgrades: Dictionary = {}  # upgrade_id -> level (int)
var unlocked_stages: Array = [1]
var total_gold: int = 0

func save() -> void:
	var data = {
		"meta_upgrades": meta_upgrades,
		"unlocked_stages": unlocked_stages,
		"total_gold": total_gold
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()

func load_save() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var text = file.get_as_text()
	file.close()
	var data = JSON.parse_string(text)
	if data is Dictionary:
		meta_upgrades = data.get("meta_upgrades", {})
		unlocked_stages = data.get("unlocked_stages", [1])
		total_gold = data.get("total_gold", 0)

func get_upgrade_level(upgrade_id: String) -> int:
	return meta_upgrades.get(upgrade_id, 0)

func get_upgrade_value(upgrade_id: String) -> float:
	return float(get_upgrade_level(upgrade_id))

func try_upgrade(upgrade_id: String, cost: int, max_level: int) -> bool:
	var current = get_upgrade_level(upgrade_id)
	if current >= max_level or total_gold < cost:
		return false
	total_gold -= cost
	meta_upgrades[upgrade_id] = current + 1
	save()
	return true

func add_gold(amount: int) -> void:
	total_gold += amount
	save()
