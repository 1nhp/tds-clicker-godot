extends Node

var particle_options = [100, 30, 5, 1, 0]
var language_options = ["en", "ru"]

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
