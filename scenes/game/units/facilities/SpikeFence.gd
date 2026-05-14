# scenes/game/units/facilities/SpikeFence.gd
class_name SpikeFence
extends Facility

func _attack(target: Enemy) -> void:
	if is_instance_valid(target):
		target.take_damage(get_damage())
