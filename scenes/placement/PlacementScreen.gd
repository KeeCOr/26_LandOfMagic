# scenes/placement/PlacementScreen.gd
extends Control

@onready var slot_row: HBoxContainer = $VBoxContainer/SlotRow
@onready var unit_list: VBoxContainer = $VBoxContainer/ScrollContainer/UnitList
@onready var start_button: Button = $VBoxContainer/ButtonRow/StartButton
@onready var back_button: Button = $VBoxContainer/ButtonRow/BackButton

var selected_unit_data = null
var selected_slot: int = -1

func _ready() -> void:
	start_button.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/game/Game.tscn"))
	back_button.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/stage_select/StageSelect.tscn"))
	_load_pools()
	_build_slots()
	_build_unit_list()

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
		btn.pressed.connect(_on_unit_selected.bind(data))
		unit_list.add_child(btn)

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
