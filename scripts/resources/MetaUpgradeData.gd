# scripts/resources/MetaUpgradeData.gd
class_name MetaUpgradeData
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var cost: int = 100
@export var max_level: int = 3
# upgrade_type 값: "slot_count", "max_hp", "start_gold", "hero_level", "xp_bonus", "facility_discount"
@export var upgrade_type: String = ""
@export var value_per_level: float = 1.0
