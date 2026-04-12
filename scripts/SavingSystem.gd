extends Node

func get_game():
	return get_tree().get_first_node_in_group("game")

func save_data():
	var game = get_game()
	var file = FileAccess.open("user://savegame.json", FileAccess.WRITE)

	var saved_data = {
		"coins": game.coins,
		"total_droopers": game.total_droopers,
		"income": game.income,
		"enemy_name": game.enemy_name,
		"drooper_cooldown": game.drooper_cooldown,
		"enemy_multiplier": game.enemy_multiplier,
		"autoclickers": game.autoclickers,	
		"droopers": game.droopers,
		"enemies": game.enemies,
		"upgrades": game.upgrades,
		"settings": game.settings,
		"language": Globals.language,
	}

	var data = JSON.stringify(saved_data, "\t")
	file.store_string(data)
	file.close()

	print("Save stored")
	
func load_data():
	var file = FileAccess.open("user://savegame.json", FileAccess.READ)
	
	if file == null:
		print("Failed to open save file.")
		return
	
	var content = file.get_as_text()
	file.close()

	var saved_data = JSON.parse_string(content)

	if saved_data == null:
		print("Failed to parse save file.")
		return

	var game = get_game()
	if game:	
		game.coins = saved_data.get("coins", 0)
		game.total_droopers = saved_data.get("total_droopers", 0)
		game.enemy_name = saved_data.get("enemy_name", "")
		game.income = saved_data.get("income", 0)
		game.drooper_cooldown = saved_data.get("drooper_cooldown", 0)
		game.enemy_multiplier = saved_data.get("enemy_multiplier", 1)	
		game.autoclickers = saved_data.get("autoclickers", 1)		
		game.droopers = saved_data.get("droopers", {})
		game.enemies = saved_data.get("enemies", {})
		game.upgrades = saved_data.get("upgrades", {})
		game.settings = saved_data.get("settings", {
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
	})
	Globals.language = saved_data.get("language")
	print("Save loaded")
