# scenes/game/units/Hero.gd
class_name Hero
extends Node2D

var unit_data: HeroData = null
var hero_level: int = 1
var current_target: Enemy = null
var attack_timer: float = 0.0
var nearby_enemies: Array = []

@onready var detection_area: Area2D = $DetectionArea
@onready var detection_shape: CollisionShape2D = $DetectionArea/CollisionShape2D

func _ready() -> void:
	if unit_data:
		_apply_data()
	hero_level = 1 + int(SaveData.get_upgrade_value("hero_level"))
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)

func _apply_data() -> void:
	var shape = CircleShape2D.new()
	shape.radius = unit_data.attack_range
	detection_shape.shape = shape

func _physics_process(delta: float) -> void:
	if not unit_data:
		return
	nearby_enemies = nearby_enemies.filter(func(e): return is_instance_valid(e))
	if not is_instance_valid(current_target) or current_target not in nearby_enemies:
		current_target = _get_nearest()
	if current_target:
		attack_timer -= delta
		if attack_timer <= 0.0:
			attack_timer = 1.0 / unit_data.attack_speed
			_attack(current_target)

func _get_nearest() -> Enemy:
	if nearby_enemies.is_empty():
		return null
	var nearest: Enemy = nearby_enemies[0]
	var min_dist = global_position.distance_squared_to(nearest.global_position)
	for e in nearby_enemies:
		var d = global_position.distance_squared_to(e.global_position)
		if d < min_dist:
			min_dist = d
			nearest = e
	return nearest

func get_damage() -> float:
	return unit_data.damage * (1.0 + (hero_level - 1) * 0.15)

func _attack(_target: Enemy) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if body is Enemy:
		nearby_enemies.append(body)

func _on_body_exited(body: Node2D) -> void:
	nearby_enemies.erase(body)

func upgrade() -> void:
	hero_level += 1
	if unit_data:
		var shape = CircleShape2D.new()
		shape.radius = unit_data.attack_range * (1.0 + (hero_level - 1) * 0.05)
		detection_shape.shape = shape
