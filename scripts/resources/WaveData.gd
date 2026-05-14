# scripts/resources/WaveData.gd
class_name WaveData
extends Resource

@export var wave_number: int = 1
@export var duration: float = 30.0
@export var spawn_interval: float = 2.0
@export var enemy_pool: Array[EnemyData] = []
@export var spawn_weights: Array[float] = []  # enemy_pool 인덱스와 1:1 대응
@export var max_enemies_at_once: int = 20
@export var is_boss_wave: bool = false
