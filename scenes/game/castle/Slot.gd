# scenes/game/castle/Slot.gd
class_name Slot
extends Node2D

var slot_index: int = 0
var unit_data = null
var unit_node: Node = null

@onready var unit_container: Node2D = $UnitContainer

func set_unit(data) -> void:
	if is_instance_valid(unit_node):
		unit_node.queue_free()
		unit_node = null

	unit_data = data
	if data == null:
		return

	var scene = load(data.scene_path) as PackedScene
	if scene == null:
		push_error("Slot: scene not found at " + data.scene_path)
		return
	unit_node = scene.instantiate()
	unit_node.unit_data = data
	unit_container.add_child(unit_node)

func clear_unit() -> void:
	set_unit(null)

func is_empty() -> bool:
	return unit_node == null
