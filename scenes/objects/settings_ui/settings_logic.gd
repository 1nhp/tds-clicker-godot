extends Node

var particle_options = [100, 30, 5, 1, 0]
var language_options = ["en", "ru"]
@export var SettingsUI: Node

signal UpdateDLCButton
signal UpdateDataFinished

var audio_volume_key
var music_volume_key
var dropdown_selection
var coin_particles_key
var language_key

func _ready() -> void:
	update_data()

func update_data():
	audio_volume_key = Globals.game.settings.get("soundvolume", 1)
	music_volume_key = Globals.game.settings.get("musicvolume", 0.5)
	dropdown_selection = Globals.game.settings.get("dropdown_selection", {})
	coin_particles_key = dropdown_selection.get("coin_particles", 0)
	language_key = dropdown_selection.get("language", 0)	
	emit_signal("UpdateDataFinished")
	
func _on_coin_particles_count_item_selected(index: int) -> void:
	Globals.game.settings["coin_particles"] = particle_options[index]
	Globals.game.settings["dropdown_selection"]["coin_particles"] = index
	
func _on_audiovolume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(2, linear_to_db(value))
	Globals.game.settings["soundvolume"] = value
	
func _on_musicvolume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(1, linear_to_db(value))
	Globals.game.settings["musicvolume"] = value

func _on_language_item_selected(index: int) -> void:
	TranslationServer.set_locale(language_options[index])
	Globals.language = language_options[index]
	Globals.game.settings["dropdown_selection"]["language"] = index

func _on_download_music_dlc_clicked(button: FancyButton) -> void:
	SettingsUI.remove_music_dlc_button.disabled = true
	SettingsUI.download_music_dlc_button.disabled = true
	Dlc.download()
	
	SettingsUI.remove_music_dlc_button.disabled = true
	Dlc.DownloadSuccesful.connect(func(): _on_download_succesful(button))
	
func _on_remove_music_dlc_clicked(button: FancyButton) -> void:
	Dlc.remove()
	UpdateDLCButton.emit()
	
func _on_download_succesful(_button):	
	SettingsUI.remove_music_dlc_button.disabled = false
	SettingsUI.download_music_dlc_button.disabled = false
	UpdateDLCButton.emit()
	MusicManager.reset()
