# scenes/game/units/heroes/Priest.gd
class_name Priest
extends Hero

func _physics_process(delta: float) -> void:
	if not unit_data:
		return
	attack_timer -= delta
	if attack_timer <= 0.0:
		attack_timer = 1.0 / unit_data.attack_speed
		GameState.heal_castle(unit_data.damage)
