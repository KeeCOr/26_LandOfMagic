# scenes/game/enemies/Troll.gd
class_name Troll
extends Enemy

func _do_attack() -> void:
	if is_instance_valid(castle_ref) and castle_ref.has_method("take_damage"):
		castle_ref.take_damage(enemy_data.damage * 1.5)
