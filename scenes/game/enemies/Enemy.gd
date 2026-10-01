# scenes/game/enemies/Enemy.gd
class_name Enemy
extends CharacterBody2D

const Art = preload("res://scripts/ArtLibrary.gd")

@export var enemy_data: EnemyData

var hp: float = 0.0
var castle_ref: Node2D = null
var attack_timer: float = 0.0

@onready var health_bar: ProgressBar = $HealthBar
@onready var sprite: Sprite2D = $Sprite2D

signal died(enemy: Enemy, xp_amount: int)

func _ready() -> void:
	if enemy_data:
		hp = enemy_data.max_hp
		Art.apply_data_sprite(sprite, enemy_data, Art.ENEMY_ART)
		sprite.position = Vector2(0, -16)
		if health_bar:
			health_bar.max_value = enemy_data.max_hp
			health_bar.value = hp

func init(castle: Node2D) -> void:
	castle_ref = castle

func _physics_process(delta: float) -> void:
	if not is_instance_valid(castle_ref) or not enemy_data:
		return
	var dist = global_position.distance_to(castle_ref.global_position)
	if dist > enemy_data.attack_range:
		var dir = (castle_ref.global_position - global_position).normalized()
		velocity = dir * enemy_data.move_speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		attack_timer -= delta
		if attack_timer <= 0.0:
			attack_timer = enemy_data.attack_interval
			_do_attack()

func _do_attack() -> void:
	if is_instance_valid(castle_ref) and castle_ref.has_method("take_damage"):
		castle_ref.take_damage(enemy_data.damage)

func take_damage(amount: float) -> void:
	hp -= amount
	if health_bar:
		health_bar.value = hp
	if hp <= 0.0:
		emit_signal("died", self, enemy_data.xp_reward)
		queue_free()
