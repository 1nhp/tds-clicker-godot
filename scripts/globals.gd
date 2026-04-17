extends Node
var game
var language = "ru"
var version = "1.2 Beta indev"
var running_from_source = false
var global_settings = {
	"skipDisclaimer": false,
	"language": "en",
}

func _ready() -> void:
	Dlc.load()
	
	# Load data from savefile to set language
	SavingSystem.load_data()
	TranslationServer.set_locale(global_settings["language"])
	
	# If running from source (not really true)
	if version.contains("indev"):
		running_from_source = true
		
	if global_settings.get("skipDisclaimer", false):
		get_tree().change_scene_to_file("res://scenes/game.tscn")
	
	
func _get_game():
	var game_ref = get_tree().get_first_node_in_group("game")
	if game_ref != null:
		game = game_ref
		print("GLOBALS: _get_game Game found!")
	else:
		print_debug("GLOBALS: _get_game Failed to find game!")
