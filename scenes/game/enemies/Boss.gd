# scenes/game/enemies/Boss.gd
class_name Boss
extends Enemy

var phase: int = 1

func take_damage(amount: float) -> void:
	super.take_damage(amount)
	if hp > 0.0 and hp <= enemy_data.max_hp * 0.5 and phase == 1:
		phase = 2

func _physics_process(delta: float) -> void:
	if not is_instance_valid(castle_ref) or not enemy_data:
		return
	var speed_mult = 1.5 if phase == 2 else 1.0
	var dist = global_position.distance_to(castle_ref.global_position)
	if dist > enemy_data.attack_range:
		var dir = (castle_ref.global_position - global_position).normalized()
		velocity = dir * enemy_data.move_speed * speed_mult
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		attack_timer -= delta
		if attack_timer <= 0.0:
			attack_timer = enemy_data.attack_interval
			_do_attack()
