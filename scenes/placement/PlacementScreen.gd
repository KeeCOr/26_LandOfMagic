# scenes/placement/PlacementScreen.gd
extends Control

const Art = preload("res://scripts/ArtLibrary.gd")

@onready var slot_row: HBoxContainer = $VBoxContainer/SlotRow
@onready var unit_list: VBoxContainer = $VBoxContainer/ScrollContainer/UnitList
@onready var start_button: Button = $VBoxContainer/ButtonRow/StartButton
@onready var back_button: Button = $VBoxContainer/ButtonRow/BackButton
@onready var title_label: Label = $VBoxContainer/TitleLabel

var selected_unit_data = null
var selected_slot: int = -1

func _ready() -> void:
	_setup_art()
	start_button.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/game/Game.tscn"))
	back_button.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/stage_select/StageSelect.tscn"))
	_load_pools()
	_build_slots()
	_build_unit_list()

func _setup_art() -> void:
	var bg := TextureRect.new()
	bg.texture = Art.texture(Art.ENVIRONMENT_ART["battlefield"])
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	move_child(bg, 0)

	var shade := ColorRect.new()
	shade.color = Color(0.05, 0.06, 0.08, 0.50)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	move_child(shade, 1)

	title_label.text = "출정 배치"
	title_label.add_theme_font_size_override("font_size", 32)
	back_button.text = "뒤로"
	start_button.text = "전투 시작"

func _load_pools() -> void:
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

func _build_slots() -> void:
	for child in slot_row.get_children():
		child.queue_free()
	for i in GameState.slot_count:
		var btn = Button.new()
		var slot_data = GameState.slots[i] if i < GameState.slots.size() else {unit_data = null}
		btn.text = "슬롯 %d: %s" % [i + 1, slot_data.unit_data.display_name if slot_data.unit_data else "비어있음"]
		btn.custom_minimum_size = Vector2(150, 44)
		btn.pressed.connect(_on_slot_clicked.bind(i))
		slot_row.add_child(btn)

func _build_unit_list() -> void:
	for child in unit_list.get_children():
		child.queue_free()
	var all = []
	all.append_array(GameState.hero_pool)
	all.append_array(GameState.facility_pool)
	for data in all:
		var btn = Button.new()
		btn.text = data.display_name
		btn.custom_minimum_size = Vector2(0, 46)
		btn.icon = _get_unit_icon(data)
		btn.expand_icon = true
		btn.pressed.connect(_on_unit_selected.bind(data))
		unit_list.add_child(btn)

func _get_unit_icon(data) -> Texture2D:
	var hero_path = Art.HERO_ART.get(data.id, "")
	if hero_path != "":
		return Art.texture(hero_path, 0.42)
	var facility_path = Art.FACILITY_ART.get(data.id, "")
	if facility_path != "":
		return Art.texture(facility_path, 0.42)
	return null

func _on_slot_clicked(index: int) -> void:
	selected_slot = index
	if selected_unit_data != null:
		GameState.slots[selected_slot].unit_data = selected_unit_data
		_build_slots()

func _on_unit_selected(data) -> void:
	selected_unit_data = data
	if selected_slot >= 0:
		GameState.slots[selected_slot].unit_data = data
		_build_slots()
