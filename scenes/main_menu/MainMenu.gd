# scenes/main_menu/MainMenu.gd
extends Control

const Art = preload("res://scripts/ArtLibrary.gd")

@onready var play_button: Button = $VBoxContainer/PlayButton
@onready var upgrade_button: Button = $VBoxContainer/UpgradeButton
@onready var quit_button: Button = $VBoxContainer/QuitButton
@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var menu_box: VBoxContainer = $VBoxContainer

func _ready() -> void:
	_setup_art()
	play_button.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/stage_select/StageSelect.tscn"))
	upgrade_button.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/ui/MetaScreen.tscn"))
	quit_button.pressed.connect(func(): get_tree().quit())

func _setup_art() -> void:
	var bg := TextureRect.new()
	bg.name = "MenuBackdrop"
	bg.texture = Art.texture(Art.ENVIRONMENT_ART["battlefield"])
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	move_child(bg, 0)

	var shade := ColorRect.new()
	shade.name = "MenuShade"
	shade.color = Color(0.06, 0.07, 0.09, 0.42)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	move_child(shade, 1)

	title_label.text = "Living Mansion"
	title_label.add_theme_font_size_override("font_size", 44)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.89, 0.56))
	title_label.add_theme_color_override("font_shadow_color", Color(0.05, 0.04, 0.04, 0.95))
	title_label.add_theme_constant_override("shadow_offset_x", 2)
	title_label.add_theme_constant_override("shadow_offset_y", 3)
	play_button.text = "게임 시작"
	upgrade_button.text = "영구 업그레이드"
	quit_button.text = "종료"

	var panel := StyleBoxFlat.new()
	panel.bg_color = Color(0.08, 0.1, 0.12, 0.72)
	panel.border_color = Color(0.78, 0.64, 0.34, 0.9)
	panel.set_border_width_all(2)
	panel.corner_radius_top_left = 8
	panel.corner_radius_top_right = 8
	panel.corner_radius_bottom_left = 8
	panel.corner_radius_bottom_right = 8
	panel.set_content_margin(SIDE_LEFT, 20)
	panel.set_content_margin(SIDE_RIGHT, 20)
	panel.set_content_margin(SIDE_TOP, 18)
	panel.set_content_margin(SIDE_BOTTOM, 18)
	menu_box.add_theme_stylebox_override("panel", panel)
	for button in [play_button, upgrade_button, quit_button]:
		button.custom_minimum_size = Vector2(260, 46)
		button.add_theme_font_size_override("font_size", 18)
