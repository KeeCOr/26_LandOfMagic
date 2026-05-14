# scenes/game/units/heroes/Mage.gd
class_name Mage
extends Hero

const PROJECTILE_SCENE = preload("res://scenes/game/projectiles/Projectile.tscn")

func _attack(_target: Enemy) -> void:
	for enemy in nearby_enemies.slice(0, 5):
		if not is_instance_valid(enemy):
			continue
		var proj = PROJECTILE_SCENE.instantiate() as Projectile
		proj.global_position = global_position
		var dir = (enemy.global_position - global_position).normalized()
		proj.init(get_damage() * 0.7, 250.0, dir)
		get_tree().current_scene.add_child(proj)
