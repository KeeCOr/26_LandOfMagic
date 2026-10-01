# scenes/stage_select/StageSelect.gd
extends Control

const Art = preload("res://scripts/ArtLibrary.gd")

@onready var stage_grid: GridContainer = $VBoxContainer/StageGrid
@onready var back_button: Button = $VBoxContainer/BackButton
@onready var title_label: Label = $VBoxContainer/TitleLabel

func _ready() -> void:
	_setup_art()
	back_button.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main_menu/MainMenu.tscn"))
	_build_stage_buttons()

func _setup_art() -> void:
	var bg := TextureRect.new()
	bg.texture = Art.texture(Art.ENVIRONMENT_ART["battlefield"])
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	move_child(bg, 0)
	var shade := ColorRect.new()
	shade.color = Color(0.05, 0.06, 0.08, 0.45)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	move_child(shade, 1)
	title_label.text = "스테이지 선택"
	title_label.add_theme_font_size_override("font_size", 32)
	back_button.text = "뒤로"

func _build_stage_buttons() -> void:
	for child in stage_grid.get_children():
		child.queue_free()
	for i in range(1, 6):
		var btn = Button.new()
		btn.text = "Stage %d" % i
		btn.custom_minimum_size = Vector2(84, 54)
		btn.disabled = not (i in SaveData.unlocked_stages)
		btn.pressed.connect(_on_stage_selected.bind(i))
		stage_grid.add_child(btn)

func _on_stage_selected(stage_number: int) -> void:
	GameState.current_stage = stage_number
	GameState.reset_run()
	get_tree().change_scene_to_file("res://scenes/placement/PlacementScreen.tscn")
