# scenes/game/units/heroes/Knight.gd
class_name Knight
extends Hero

func _attack(target: Enemy) -> void:
	if is_instance_valid(target):
		target.take_damage(get_damage())
