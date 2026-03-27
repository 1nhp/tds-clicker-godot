extends Node

@export var graphics_tab: Control
@export var audio_tab: Control
@export var game_tab: Control
@export var game_version: Label
@export var anim_player: Node
@export var SettingsLogicNode: Node
@export var audio_volume_slider: Slider
@export var music_volume_slider: Slider
@export var coin_particles_dropdown: OptionButton
@export var language_dropdown: OptionButton
@export var download_music_dlc_button: Button
@export var remove_music_dlc_button: Button
@export var root: Node

var closing: bool

func _ready() -> void:
	Globals.game.MenuClosing.connect(_on_menu_closing)
	game_version.text = Globals.version
	
	if Globals.game.settings["ui_animations"]:
		anim_player.play("anim")

func update_ui():
	audio_volume_slider.value = SettingsLogicNode.audio_volume_key
	music_volume_slider.value = SettingsLogicNode.music_volume_key
	coin_particles_dropdown.selected = SettingsLogicNode.coin_particles_key
	language_dropdown.selected = SettingsLogicNode.language_key

func _on_close_button_clicked(_button: FancyButton) -> void:
	closing = Globals.game.menu(Globals.game.actions.CLOSE, "ui_settings", closing, anim_player, root)
	
func _on_menu_closing():
	Globals.game.settings_button.disabled = false

func _switch_tab(tab):
	for t in [graphics_tab,audio_tab,game_tab]:
		t.visible = false
	tab.visible = true

func _on_graphics_tab_button_clicked(_button: FancyButton) -> void: _switch_tab(graphics_tab)
func _on_audio_tab_button_clicked(_button: FancyButton) -> void: _switch_tab(audio_tab)
func _on_game_tab_button_clicked(_button: FancyButton) -> void: _switch_tab(game_tab)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if closing: root.queue_free()
	
func update_music_dlc_button_text():
	if Dlc.dlc.has(true):
		download_music_dlc_button.text = tr("download_music_dlc_btn")
	else:
		download_music_dlc_button.text = tr("redownload_music_dlc_btn")

func _on_settings_logic_update_dlc_button() -> void: update_music_dlc_button_text()
func _on_settings_logic_update_data_finished() -> void: update_ui()
