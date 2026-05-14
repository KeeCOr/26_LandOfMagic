# scenes/game/castle/Castle.gd
class_name Castle
extends CharacterBody2D

const SPEED = 120.0

@onready var slots_container: Node2D = $SlotsContainer

var slots: Array = []

func _ready() -> void:
	GameState.castle_hp = GameState.castle_max_hp
	_setup_slots()

func _physics_process(_delta: float) -> void:
	var dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = dir * SPEED
	move_and_slide()

func _setup_slots() -> void:
	for child in slots_container.get_children():
		child.queue_free()
	slots.clear()

	var count = GameState.slot_count
	var spacing = 50.0
	var total_width = (count - 1) * spacing

	for i in count:
		var slot = preload("res://scenes/game/castle/Slot.tscn").instantiate()
		slot.position = Vector2(-total_width / 2.0 + i * spacing, 0.0)
		slot.slot_index = i
		slots_container.add_child(slot)
		slots.append(slot)

func take_damage(amount: float) -> void:
	GameState.take_castle_damage(amount)

func heal(amount: float) -> void:
	GameState.heal_castle(amount)

func place_unit(slot_index: int, unit_data) -> void:
	if slot_index < 0 or slot_index >= slots.size():
		return
	slots[slot_index].set_unit(unit_data)
