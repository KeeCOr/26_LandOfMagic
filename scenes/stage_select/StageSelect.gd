# scenes/stage_select/StageSelect.gd
extends Control

@onready var stage_grid: GridContainer = $VBoxContainer/StageGrid
@onready var back_button: Button = $VBoxContainer/BackButton

func _ready() -> void:
	back_button.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main_menu/MainMenu.tscn"))
	_build_stage_buttons()

func _build_stage_buttons() -> void:
	for child in stage_grid.get_children():
		child.queue_free()
	for i in range(1, 6):
		var btn = Button.new()
		btn.text = "Stage %d" % i
		btn.disabled = not (i in SaveData.unlocked_stages)
		btn.pressed.connect(_on_stage_selected.bind(i))
		stage_grid.add_child(btn)

func _on_stage_selected(stage_number: int) -> void:
	GameState.current_stage = stage_number
	GameState.reset_run()
	get_tree().change_scene_to_file("res://scenes/placement/PlacementScreen.tscn")
