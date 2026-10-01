extends Control

const ROOMS := {
	"응접실": {"risk": "낮음", "reward": "가족 초상화 단서", "reason": "탐색의 출발점"},
	"서재": {"risk": "중간", "reward": "비밀 장부와 열쇠", "reason": "찢긴 편지가 가리키는 방"},
	"지하실": {"risk": "높음", "reward": "사건의 핵심 증거", "reason": "서재의 열쇠가 필요함"},
}

var title_label: Label
var status_label: Label
var investigate_button: Button
var result_panel: PanelContainer
var result_title: Label
var result_change: Label
var result_next: Label
var room_choices: VBoxContainer

func _ready() -> void:
	_build_ui()
	GameState.reset_exploration()
	_show_room("응접실")

func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color("11131b")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 48)
	margin.add_theme_constant_override("margin_right", 48)
	margin.add_theme_constant_override("margin_top", 36)
	margin.add_theme_constant_override("margin_bottom", 36)
	add_child(margin)
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 16)
	margin.add_child(layout)
	title_label = Label.new()
	title_label.add_theme_font_size_override("font_size", 32)
	layout.add_child(title_label)
	status_label = Label.new()
	status_label.add_theme_color_override("font_color", Color("e7c977"))
	layout.add_child(status_label)
	var instruction := Label.new()
	instruction.text = "빛나는 오브젝트를 조사해 다음 방으로 이어지는 단서를 찾으세요."
	instruction.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(instruction)
	investigate_button = Button.new()
	investigate_button.custom_minimum_size = Vector2(0, 56)
	investigate_button.pressed.connect(_on_investigate)
	layout.add_child(investigate_button)
	result_panel = PanelContainer.new()
	result_panel.visible = false
	layout.add_child(result_panel)
	var result_box := VBoxContainer.new()
	result_box.add_theme_constant_override("separation", 8)
	result_panel.add_child(result_box)
	result_title = Label.new()
	result_title.add_theme_font_size_override("font_size", 24)
	result_box.add_child(result_title)
	result_change = Label.new()
	result_change.add_theme_color_override("font_color", Color("8fd6a4"))
	result_box.add_child(result_change)
	result_next = Label.new()
	result_next.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result_box.add_child(result_next)
	var heading := Label.new()
	heading.text = "다음 행동"
	heading.add_theme_font_size_override("font_size", 22)
	layout.add_child(heading)
	room_choices = VBoxContainer.new()
	room_choices.add_theme_constant_override("separation", 8)
	layout.add_child(room_choices)
	var back_button := Button.new()
	back_button.text = "메인 메뉴로"
	back_button.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main_menu/MainMenu.tscn"))
	layout.add_child(back_button)

func _show_room(room_name: String) -> void:
	GameState.enter_exploration_room(room_name)
	var room: Dictionary = ROOMS[room_name]
	title_label.text = room_name
	status_label.text = "관계 %d/100  ·  위험 %s  ·  기대 보상: %s" % [GameState.relationship, room.risk, room.reward]
	result_panel.visible = false
	investigate_button.disabled = GameState.discovered_clues.has(_clue_id_for_room(room_name))
	investigate_button.text = "조사 완료" if investigate_button.disabled else "이 방의 단서 조사하기"
	_refresh_choices()

func _on_investigate() -> void:
	var result: Dictionary
	match GameState.current_room:
		"응접실": result = GameState.discover_clue("torn_letter", "찢긴 편지", 5, "서재")
		"서재": result = GameState.discover_clue("brass_key", "황동 열쇠", -3, "지하실")
		_: result = GameState.discover_clue("sealed_record", "봉인된 기록", 8, "현재 방을 더 조사한다")
	result_panel.visible = true
	result_title.text = result.headline
	result_change.text = "%s  ·  현재 관계 %d/100" % [result.relationship_text, GameState.relationship]
	result_next.text = "단서가 연 다음 선택: %s\n아래 방 카드에서 위험과 보상을 비교해 결정하세요." % result.next_choice
	investigate_button.disabled = true
	investigate_button.text = "조사 완료"
	_refresh_choices()

func _clue_id_for_room(room_name: String) -> String:
	return {"응접실": "torn_letter", "서재": "brass_key", "지하실": "sealed_record"}.get(room_name, "")

func _refresh_choices() -> void:
	for child in room_choices.get_children():
		child.queue_free()
	var destinations: Array[String] = []
	if GameState.discovered_clues.has("brass_key"):
		destinations = ["지하실", "응접실"]
	elif GameState.discovered_clues.has("torn_letter"):
		destinations = ["서재", "응접실"]
	else:
		var locked := Button.new()
		locked.text = "서재 · 잠김 — 응접실에서 단서를 먼저 찾으세요"
		locked.disabled = true
		room_choices.add_child(locked)
		return
	for destination in destinations:
		var info: Dictionary = ROOMS[destination]
		var button := Button.new()
		button.text = "%s  | 위험 %s | %s\n%s" % [destination, info.risk, info.reward, info.reason]
		button.custom_minimum_size = Vector2(0, 62)
		button.pressed.connect(func(): _show_room(destination))
		room_choices.add_child(button)
