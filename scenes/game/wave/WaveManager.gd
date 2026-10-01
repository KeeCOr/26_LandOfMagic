# scenes/game/wave/WaveManager.gd
class_name WaveManager
extends Node

@export var wave_data_list: Array[WaveData] = []

var current_wave_index: int = -1
var active_enemies: Array = []
var spawn_timer: float = 0.0
var wave_timer: float = 0.0
var is_wave_active: bool = false
var castle: Castle = null
var enemy_container: Node = null

signal wave_started(wave_number: int)
signal wave_cleared(wave_number: int)
signal all_waves_cleared()

func init(castle_node: Castle, container: Node) -> void:
	castle = castle_node
	enemy_container = container

func start_next_wave() -> void:
	current_wave_index += 1
	if current_wave_index >= wave_data_list.size():
		emit_signal("all_waves_cleared")
		return
	var wave = wave_data_list[current_wave_index]
	wave_timer = wave.duration
	spawn_timer = 0.0
	is_wave_active = true
	emit_signal("wave_started", current_wave_index + 1)

func _process(delta: float) -> void:
	if not is_wave_active:
		return
	var wave = wave_data_list[current_wave_index]

	spawn_timer -= delta
	if spawn_timer <= 0.0 and active_enemies.size() < wave.max_enemies_at_once:
		spawn_timer = wave.spawn_interval
		_spawn_enemy(wave)

	wave_timer -= delta
	active_enemies = active_enemies.filter(func(e): return is_instance_valid(e))

	if wave_timer <= 0.0 and active_enemies.is_empty():
		is_wave_active = false
		emit_signal("wave_cleared", current_wave_index + 1)

func _spawn_enemy(wave: WaveData) -> void:
	if wave.enemy_pool.is_empty() or not is_instance_valid(castle):
		return
	var data = _pick_enemy(wave)
	var scene = load(data.scene_path) as PackedScene
	if not scene:
		push_error("WaveManager: scene not found at " + data.scene_path)
		return
	var enemy = scene.instantiate() as Enemy
	enemy.enemy_data = data
	enemy.init(castle)
	enemy.died.connect(_on_enemy_died)
	enemy.global_position = castle.global_position + _random_edge_offset()
	enemy_container.add_child(enemy)
	active_enemies.append(enemy)

func _random_edge_offset() -> Vector2:
	var dist = 500.0 + randf() * 100.0
	var angle = randf() * TAU
	return Vector2(cos(angle), sin(angle)) * dist

func _pick_enemy(wave: WaveData) -> EnemyData:
	if wave.spawn_weights.is_empty():
		return wave.enemy_pool[0]
	var total = 0.0
	for w in wave.spawn_weights:
		total += w
	var r = randf() * total
	var cum = 0.0
	for i in wave.enemy_pool.size():
		cum += wave.spawn_weights[i]
		if r <= cum:
			return wave.enemy_pool[i]
	return wave.enemy_pool[0]

func _on_enemy_died(enemy: Enemy, xp_amount: int) -> void:
	active_enemies.erase(enemy)
	GameState.gain_xp(float(xp_amount))
