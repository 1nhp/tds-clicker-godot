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
@export var reset_savedata_button: Button
@export var root: Node

var closing: bool
var resetdata_confirmation: int

func _ready() -> void:
	game_version.text = Globals.version
	
	if Globals.game.settings["ui_animations"]:
		anim_player.play("anim")

	update_music_dlc_button_text()

func update_ui():
	audio_volume_slider.value = SettingsLogicNode.audio_volume_key
	music_volume_slider.value = SettingsLogicNode.music_volume_key
	coin_particles_dropdown.selected = SettingsLogicNode.coin_particles_key
	language_dropdown.selected = SettingsLogicNode.language_key

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
	if Dlc.dlc.has(false):
		download_music_dlc_button.text = tr("download_music_dlc_btn")
	else:
		download_music_dlc_button.text = tr("redownload_music_dlc_btn")

func _on_settings_logic_update_dlc_button() -> void: update_music_dlc_button_text()
func _on_settings_logic_update_data_finished() -> void: 
	update_ui()


func _on_credits_clicked(_button: FancyButton) -> void:
	var credits = object.create("credits", Vector2.ZERO, "/root/game/UI")
	Globals.game.menuController.open_menu(credits, credits.get_node("AnimationPlayer"), false)

func _on_close_button_pressed() -> void:
	Globals.game.menuController.close_menu(root, anim_player, "anim", true, true)
	Globals.game.settings_button.disabled = false
	SoundManager.stop_sound("PolicePatrol")
	SoundManager.stop_sound("PolicePatrol2")
	SoundManager.stop_sound("PolicePatrol3")

func _on_resetsavedata_pressed() -> void:
	match resetdata_confirmation:
		0: 
			reset_savedata_button.text = "U sure?"
			SoundManager.play_sound("Huh")
		1: 
			reset_savedata_button.text = "Really really?"
			SoundManager.play_sound("Nope")
		2: 
			reset_savedata_button.text = "Think you can slip it?"
			SoundManager.play_sound("PolicePatrol")
		3:  
			reset_savedata_button.text = "It does NOT grow on trees u know?"
			SoundManager.stop_sound("PolicePatrol")
			SoundManager.play_sound("PolicePatrol2", 0, 0, false)
		4:
			reset_savedata_button.text = "THIS IS UNRECOVERABLE"
			SoundManager.stop_sound("PolicePatrol2")
			SoundManager.play_sound("PolicePatrol3", 0, 0, false)
		5:
			SoundManager.stop_sound("PolicePatrol3")
			resetdata_confirmation = -1
			reset_savedata_button.disabled = true
			SoundManager.play_sound("Explosion")
			reset_savedata_button.text = "Resetting..."
			SavingSystem.reset_data()
			SceneManager.reload()
			
	resetdata_confirmation += 1
