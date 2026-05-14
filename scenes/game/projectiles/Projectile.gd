# scenes/game/projectiles/Projectile.gd
class_name Projectile
extends Area2D

var damage: float = 0.0
var speed: float = 300.0
var direction: Vector2 = Vector2.RIGHT
var target: Node2D = null

func init(dmg: float, spd: float, dir: Vector2, tgt: Node2D = null) -> void:
	damage = dmg
	speed = spd
	direction = dir.normalized()
	target = tgt

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if is_instance_valid(target):
		direction = (target.global_position - global_position).normalized()
	global_position += direction * speed * delta
	var cam_pos = Vector2.ZERO
	var cam = get_viewport().get_camera_2d()
	if cam:
		cam_pos = cam.global_position
	if global_position.distance_to(cam_pos) > 1200.0:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
