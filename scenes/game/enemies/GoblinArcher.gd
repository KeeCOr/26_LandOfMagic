# scenes/game/enemies/GoblinArcher.gd
class_name GoblinArcher
extends Enemy

const PROJECTILE_SCENE = preload("res://scenes/game/projectiles/Projectile.tscn")

func _do_attack() -> void:
	if not is_instance_valid(castle_ref):
		return
	var proj = PROJECTILE_SCENE.instantiate() as Projectile
	proj.global_position = global_position
	var dir = (castle_ref.global_position - global_position).normalized()
	proj.init(enemy_data.damage, enemy_data.projectile_speed, dir)
	get_tree().current_scene.add_child(proj)
