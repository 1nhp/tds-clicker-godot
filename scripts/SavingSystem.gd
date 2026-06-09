extends Node

const SAVE_PATH := "user://savegame.json"
const SAVE_VERSION := 1

const DEFAULT_SAVE := {
	"version": SAVE_VERSION,
	"coins": 0,
	"total_droopers": 0,
	"income": 0,
	"enemies_killed": 0,
	"coins_earned": 0,
	"total_playtime_seconds": 0,
	"enemy_name": "Normal",
	"drooper_cooldown": 0,
	"enemy_multiplier": 1.0,
	"autoclickers": 0,
	"first_time": 0,
	"droopers": {},
	"enemies": {},
	"upgrades": {},
	"settings": {
		"blur_bg": true,
		"coin_particles": 100,
		"enemy_animations": true,
		"ui_animations": true,
		"musicvolume": 0.5,
		"soundvolume": 1.0,
		"dropdown_selection": {
			"coin_particles": 1,
			"language": 1,
		}
	},
	"global_settings": {
		"skipDisclaimer": false,
		"language": "en",
	}
}

func get_game(): return get_tree().get_first_node_in_group("game")
func _deep_copy(data: Dictionary) -> Dictionary: return data.duplicate(true)

func save_data():
	var game = get_game()
	if game == null: return
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		print("Failed to open save file for writing.")
		return

	var data := _deep_copy(DEFAULT_SAVE)

	data["coins"] = game.coins
	data["total_droopers"] = game.total_droopers
	data["income"] = game.income
	data["enemies_killed"] = game.enemies_killed
	data["coins_earned"] = game.coins_earned
	data["total_playtime_seconds"] = game.total_playtime_seconds
	data["enemy_name"] = game.enemy_name
	data["drooper_cooldown"] = game.drooper_cooldown
	data["enemy_multiplier"] = game.enemy_multiplier
	data["autoclickers"] = game.autoclickers
	data["first_time"] = game.first_time
	data["droopers"] = _deep_copy(game.droopers)
	data["enemies"] = _deep_copy(game.enemies)
	data["upgrades"] = _deep_copy(game.upgrades)
	data["settings"] = _deep_copy(game.settings)
	data["global_settings"] = _deep_copy(Globals.global_settings)

	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	print("Save stored")

func load_data():
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found. Using defaults.")
		_apply_data(_deep_copy(DEFAULT_SAVE))
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		print("Failed to open save file.")
		return

	var content = file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(content)
	var data: Dictionary = parsed
	var final_data = _merge_with_defaults(data, DEFAULT_SAVE)
	_apply_data(final_data)
	print("Save loaded")

func _apply_data(data: Dictionary):
	var game = get_game()
	if game == null: return

	game.coins = data["coins"]
	game.total_droopers = data["total_droopers"]
	game.income = data["income"]
	game.enemies_killed = data["enemies_killed"]
	game.coins_earned = data["coins_earned"]
	game.total_playtime_seconds = data["total_playtime_seconds"]
	game.enemy_name = data["enemy_name"]
	game.drooper_cooldown = data["drooper_cooldown"]
	game.enemy_multiplier = data["enemy_multiplier"]
	game.autoclickers = data["autoclickers"]
	game.first_time = data["first_time"]
	game.droopers = _deep_copy(data["droopers"])
	game.enemies = _deep_copy(data["enemies"])
	game.upgrades = _deep_copy(data["upgrades"])
	game.settings = _deep_copy(data["settings"])

	Globals.global_settings = _deep_copy(data["global_settings"])

func _merge_with_defaults(data: Dictionary, defaults: Dictionary) -> Dictionary:
	var result := {}

	for key in defaults.keys():
		if data.has(key):
			if typeof(defaults[key]) == TYPE_DICTIONARY:
				result[key] = _merge_with_defaults(data[key], defaults[key])
			else:
				result[key] = data[key]
		else:
			result[key] = _deep_copy(defaults[key])
	return result

func reset_data():
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)

	_apply_data(_deep_copy(DEFAULT_SAVE))
