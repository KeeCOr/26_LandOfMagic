# scripts/resources/EnemyData.gd
class_name EnemyData
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var scene_path: String = ""
@export var max_hp: float = 30.0
@export var move_speed: float = 80.0
@export var damage: float = 5.0
@export var attack_range: float = 60.0
@export var xp_reward: int = 1
@export var is_ranged: bool = false
@export var attack_interval: float = 1.0
@export var projectile_speed: float = 200.0  # is_ranged=true일 때만 사용
