# scenes/ui/ChoiceButton.gd
class_name ChoiceButton
extends Button

@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var desc_label: Label = $VBoxContainer/DescLabel

func setup(data) -> void:
	name_label.text = data.display_name
	desc_label.text = data.description
