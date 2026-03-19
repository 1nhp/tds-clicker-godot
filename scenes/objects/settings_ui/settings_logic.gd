extends Node

@onready var game = get_tree().get_first_node_in_group("game")

func _ready() -> void:
	var audiovolume = get_tree().get_first_node_in_group("audiovolume")
	var musicvolume = get_tree().get_first_node_in_group("musicvolume")	
	audiovolume.value = game.settings["soundvolume"]
	musicvolume.value = game.settings["musicvolume"]

func _on_coin_particles_count_item_selected(index: int) -> void:
	print(game.settings)
	print(index)
	var particle_options = [100, 30, 5, 1, 0]
	game.settings["coin_particles"] = particle_options[index]

func _on_audiovolume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(2, linear_to_db(value))
	game.settings["soundvolume"] = value
	
func _on_musicvolume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(1, linear_to_db(value))
	game.settings["musicvolume"] = value
