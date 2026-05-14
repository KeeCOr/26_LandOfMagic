# scenes/game/units/facilities/Catapult.gd
class_name Catapult
extends Facility

const PROJECTILE_SCENE = preload("res://scenes/game/projectiles/Projectile.tscn")

func _attack(target: Enemy) -> void:
	var proj = PROJECTILE_SCENE.instantiate() as Projectile
	proj.global_position = global_position
	var dir = (target.global_position - global_position).normalized()
	proj.init(get_damage(), 150.0, dir, target)
	get_tree().current_scene.add_child(proj)
