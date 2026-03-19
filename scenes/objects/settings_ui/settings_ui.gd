extends Control
@onready var game = get_tree().get_first_node_in_group("game")
@onready var graphicstab = get_tree().get_first_node_in_group("graphicstab")
@onready var audiotab = get_tree().get_first_node_in_group("audiotab")

func _ready() -> void:
	$Window/Header/gamever.text = game.version

func _on_close_button_clicked(button: FancyButton) -> void:
	queue_free()
	get_tree().get_first_node_in_group("settings_button").disabled = false
	game._blur_screen(false)

func _switch_tab(tab):
	for t in [graphicstab,audiotab]:
		t.visible = false
	tab.visible = true


func _on_graphics_tab_button_clicked(button: FancyButton) -> void: _switch_tab(graphicstab)
func _on_audio_tab_button_clicked(button: FancyButton) -> void: _switch_tab(audiotab)
