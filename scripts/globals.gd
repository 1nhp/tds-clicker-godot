extends Node
var game
var language = "ru"

func _ready() -> void:
	SavingSystem.load_data()
	TranslationServer.set_locale(language)
	
func _get_game():
	var game_ref = get_tree().get_first_node_in_group("game")
	if game_ref != null:
		game = game_ref
		print("GLOBALS: _get_game Game found!")
	else:
		print_debug("GLOBALS: _get_game Failed to find game!")
