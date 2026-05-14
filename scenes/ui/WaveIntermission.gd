# scenes/ui/WaveIntermission.gd
class_name WaveIntermission
extends CanvasLayer

const AUTO_START_TIME = 15.0

@onready var wave_label: Label = $PanelContainer/VBoxContainer/WaveLabel
@onready var timer_label: Label = $PanelContainer/VBoxContainer/TimerLabel
@onready var slot_list: VBoxContainer = $PanelContainer/VBoxContainer/ScrollContainer/SlotList
@onready var ready_button: Button = $PanelContainer/VBoxContainer/ReadyButton

var time_remaining: float = AUTO_START_TIME

signal intermission_done()

func _ready() -> void:
	ready_button.pressed.connect(_on_ready_pressed)

func show_intermission(wave_number: int, _castle) -> void:
	visible = true
	time_remaining = AUTO_START_TIME
	wave_label.text = "Wave %d Clear!" % wave_number
	_refresh_slot_list()

func _process(delta: float) -> void:
	if not visible:
		return
	time_remaining -= delta
	timer_label.text = "자동 시작: %ds" % int(ceil(time_remaining))
	if time_remaining <= 0.0:
		_finish()

func _refresh_slot_list() -> void:
	for child in slot_list.get_children():
		child.queue_free()
	for i in GameState.slot_count:
		var label = Label.new()
		var slot_data = GameState.slots[i]
		if slot_data.unit_data:
			label.text = "슬롯 %d: %s" % [i + 1, slot_data.unit_data.display_name]
		else:
			label.text = "슬롯 %d: 비어있음" % (i + 1)
		slot_list.add_child(label)

func _on_ready_pressed() -> void:
	_finish()

func _finish() -> void:
	visible = false
	emit_signal("intermission_done")
