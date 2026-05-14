# scenes/game/units/heroes/Archer.gd
class_name Archer
extends Hero

const PROJECTILE_SCENE = preload("res://scenes/game/projectiles/Projectile.tscn")

func _attack(target: Enemy) -> void:
	var proj = PROJECTILE_SCENE.instantiate() as Projectile
	proj.global_position = global_position
	var dir = (target.global_position - global_position).normalized()
	proj.init(get_damage(), 300.0, dir)
	get_tree().current_scene.add_child(proj)
