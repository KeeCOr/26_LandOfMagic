# scenes/ui/LevelUpPopup.gd
class_name LevelUpPopup
extends CanvasLayer

@onready var choices_container: HBoxContainer = $PanelContainer/VBoxContainer/ChoicesContainer

const CHOICE_BUTTON_SCENE = preload("res://scenes/ui/ChoiceButton.tscn")

signal choice_made(data)

func show_choices(choices: Array) -> void:
	get_tree().paused = true
	visible = true
	for child in choices_container.get_children():
		child.queue_free()
	for data in choices:
		var btn = CHOICE_BUTTON_SCENE.instantiate() as ChoiceButton
		btn.setup(data)
		btn.pressed.connect(_on_choice_selected.bind(data))
		choices_container.add_child(btn)

func _on_choice_selected(data) -> void:
	get_tree().paused = false
	visible = false
	emit_signal("choice_made", data)
