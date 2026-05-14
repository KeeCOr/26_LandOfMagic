# scenes/main_menu/MainMenu.gd
extends Control

@onready var play_button: Button = $VBoxContainer/PlayButton
@onready var upgrade_button: Button = $VBoxContainer/UpgradeButton
@onready var quit_button: Button = $VBoxContainer/QuitButton

func _ready() -> void:
	play_button.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/stage_select/StageSelect.tscn"))
	upgrade_button.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/ui/MetaScreen.tscn"))
	quit_button.pressed.connect(func(): get_tree().quit())
