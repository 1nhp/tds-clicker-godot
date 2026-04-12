extends Node

@export var InfoText: RichTextLabel
@export var VersionButtons: VBoxContainer

func _ready() -> void:
	for child in VersionButtons.get_children():
		var data = child.get_meta("data")
		child.text = data["name"]
		child.clicked.connect(_on_changelog_button_pressed.bind(data))
		
func _on_changelog_button_pressed(button: FancyButton, data):
	InfoText.text = data["text"]
