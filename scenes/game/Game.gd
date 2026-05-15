# scenes/game/Game.gd
class_name Game
extends Node2D

const Art = preload("res://scripts/ArtLibrary.gd")

@onready var castle: Castle = $Castle
@onready var wave_manager: WaveManager = $WaveManager
@onready var enemy_container: Node2D = $EnemyContainer
@onready var hud: HUD = $HUD
@onready var levelup_popup: LevelUpPopup = $LevelUpPopup
@onready var wave_intermission: WaveIntermission = $WaveIntermission
@onready var result_screen = $ResultScreen

var total_waves: int = 0

func _ready() -> void:
	GameState.reset_run()
	_setup_stage_art()
	_load_unit_pools()
	_connect_signals()
	wave_manager.init(castle, enemy_container)
	total_waves = wave_manager.wave_data_list.size()
	wave_manager.start_next_wave()

func _setup_stage_art() -> void:
	var bg := Sprite2D.new()
	bg.name = "BattlefieldBackdrop"
	bg.texture = Art.texture(Art.ENVIRONMENT_ART["battlefield"])
	bg.centered = true
	bg.position = Vector2(0, 0)
	bg.z_index = -100
	add_child(bg)
	move_child(bg, 0)

	var vignette := CanvasLayer.new()
	vignette.name = "MoodOverlay"
	vignette.layer = -1
	add_child(vignette)
	var shade := ColorRect.new()
	shade.color = Color(0.07, 0.08, 0.1, 0.16)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	vignette.add_child(shade)

func _load_unit_pools() -> void:
	GameState.hero_pool.clear()
	GameState.facility_pool.clear()
	var hero_dir = DirAccess.open("res://resources/heroes/")
	if hero_dir:
		hero_dir.list_dir_begin()
		var fname = hero_dir.get_next()
		while fname != "":
			if fname.ends_with(".tres"):
				var data = load("res://resources/heroes/" + fname) as HeroData
				if data:
					GameState.hero_pool.append(data)
			fname = hero_dir.get_next()
	var fac_dir = DirAccess.open("res://resources/facilities/")
	if fac_dir:
		fac_dir.list_dir_begin()
		var fname2 = fac_dir.get_next()
		while fname2 != "":
			if fname2.ends_with(".tres"):
				var data = load("res://resources/facilities/" + fname2) as FacilityData
				if data:
					GameState.facility_pool.append(data)
			fname2 = fac_dir.get_next()

func _connect_signals() -> void:
	wave_manager.wave_started.connect(_on_wave_started)
	wave_manager.wave_cleared.connect(_on_wave_cleared)
	wave_manager.all_waves_cleared.connect(_on_all_waves_cleared)
	GameState.level_up_triggered.connect(levelup_popup.show_choices)
	GameState.castle_died.connect(_on_castle_died)
	levelup_popup.choice_made.connect(_on_choice_made)
	wave_intermission.intermission_done.connect(_on_intermission_done)
	result_screen.continue_pressed.connect(_on_result_continue)

func _on_wave_started(wave_number: int) -> void:
	hud.set_wave(wave_number, total_waves)

func _on_wave_cleared(wave_number: int) -> void:
	GameState.gold += 50
	wave_intermission.show_intermission(wave_number, castle)

func _on_all_waves_cleared() -> void:
	var gold_reward = 200
	GameState.gold += gold_reward
	SaveData.add_gold(gold_reward)
	if not (GameState.current_stage + 1) in SaveData.unlocked_stages:
		SaveData.unlocked_stages.append(GameState.current_stage + 1)
	SaveData.save()
	result_screen.show_victory(GameState.current_stage, gold_reward)

func _on_castle_died() -> void:
	result_screen.show_defeat(GameState.current_stage, wave_manager.current_wave_index + 1)

func _on_result_continue() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu/MainMenu.tscn")

func _on_choice_made(data) -> void:
	var placed = false
	for i in castle.slots.size():
		if castle.slots[i].is_empty():
			castle.place_unit(i, data)
			GameState.slots[i].unit_data = data
			placed = true
			break
	if not placed and castle.slots.size() > 0:
		castle.place_unit(0, data)
		GameState.slots[0].unit_data = data

func _on_intermission_done() -> void:
	wave_manager.start_next_wave()
