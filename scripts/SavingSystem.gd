extends Node

# 32 byte key (AES-256)
var AES_KEY = "my_super_secret_key_32_bytes!!!!".to_utf8_buffer()

func get_game():
	return get_tree().get_first_node_in_group("game")

func save_data():
	var game = get_game()
	var file = FileAccess.open("user://savegame.dat", FileAccess.WRITE)

	var saved_data = {
		"coins": game.coins,
		"total_droopers": game.total_droopers,
		"income": game.income,
		"droopers": game.droopers,
		"enemies": game.enemies,
		"enemy_name": game.enemy_name,
		"drooper_cooldown": game.drooper_cooldown,
		"upgrades": game.upgrades,
		"enemy_multiplier": game.enemy_multiplier
	}

	var json_string = JSON.stringify(saved_data)
	var data = json_string.to_utf8_buffer()
	
	while data.size() % 16 != 0:
		data.append(0)

	var aes = AESContext.new()
	aes.start(AESContext.MODE_ECB_ENCRYPT, AES_KEY)
	var encrypted = aes.update(data)
	aes.finish()
	
	file.store_buffer(encrypted)
	file.close()

	print("Encrypted save written.")


func load_data():
	if not FileAccess.file_exists("user://savegame.dat"):
		print("No save file found.")
		return

	var file = FileAccess.open("user://savegame.dat", FileAccess.READ)

	var encrypted = file.get_buffer(file.get_length())
	file.close()

	var aes = AESContext.new()
	aes.start(AESContext.MODE_ECB_DECRYPT, AES_KEY)
	var decrypted = aes.update(encrypted)
	aes.finish()

	var json_string = decrypted.get_string_from_utf8().strip_edges()
	var saved_data = JSON.parse_string(json_string)

	var game = get_game()

	game.coins = saved_data["coins"]
	game.total_droopers = saved_data["total_droopers"]
	game.income = saved_data["income"]
	game.droopers = saved_data["droopers"]
	game.enemies = saved_data["enemies"]
	game.enemy_name = saved_data["enemy_name"]
	game.drooper_cooldown = saved_data["drooper_cooldown"]
	game.upgrades = saved_data["upgrades"]	
	game.enemy_multiplier = saved_data["enemy_multiplier"]	
	
	print("Encrypted save loaded: ", saved_data)
