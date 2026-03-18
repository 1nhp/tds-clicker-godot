extends Node

@onready var game = get_tree().get_first_node_in_group("game")
@onready var enemy = get_tree().get_first_node_in_group("enemy")
@onready var StoreUI = get_tree().get_first_node_in_group("StoreUI")
@onready var StoreManager = get_tree().get_first_node_in_group("StoreManager")

func _on_buy_clicked(button):
	if game.enemies.get(StoreManager.current_item.name,false):
		enemy._update_enemy(StoreManager.current_item.id)
		game.enemy_name = StoreManager.current_item.id
		return
	
	if game.coins < StoreManager.current_item.price:
		_error()
		return

	match StoreManager.current_item.type:
		"Enemy":
			_buy_enemy()
		"Drooper":
			_buy_drooper()
		
func _buy_enemy():

	object.create("coin_particles", Vector2(StoreUI.enemy_content_container.get_node("buy").global_position.x + 100, StoreUI.enemy_content_container.get_node("buy").global_position.y + 40))
	game.coins -= StoreManager.current_item.price
	game.enemies[StoreManager.current_item.name] = true
	game.enemy_name = StoreManager.current_item.id
	enemy._update_enemy(StoreManager.current_item.id)
	SoundManager.play_sound("Upgrade")
	game._update_coin_count()
	StoreUI._update_enemy_button()

func _buy_drooper():
	object.create("coin_particles", Vector2(StoreUI.drooper_content_container.get_node("buy").global_position.x + 100, StoreUI.drooper_content_container.get_node("buy").global_position.y + 40))
	game.coins -= StoreManager.current_item.price
	game.total_droopers += 1
	game.droopers[StoreManager.current_item.name] = game.droopers.get(StoreManager.current_item.name,0) + 1
	game.income += StoreManager.current_item.coin_award
	SoundManager.play_sound("Upgrade")
	game._update_coin_count()


func _buy_upgrade(item, button):
	var price = int(item.base_price * pow(item.price_multiplier,item.level))
	if game.coins < price:
		_error()
		return
	
	if item.level >= item.max_level:
		_error("Upgrade is already maxed!")
		return

	match item.id:
		"drooper_cooldown":
			var min_cooldown = 0.1
	
	object.create("coin_particles", Vector2(button.global_position.x + 100, button.global_position.y + 40))
	game.coins -= price
	game._update_coin_count()
	item.level += 1
	game.upgrades[item.id] = item.level
	
	_apply_upgrade_effect(item.id)
	SoundManager.play_sound("Upgrade")
	StoreUI._update_upgrade_container(StoreManager.upgrade_containers[item.id],item)
	
func _apply_upgrade_effect(id):
	match id:
		"drooper_cooldown":
			game.drooper_cooldown = max(0.0,game.drooper_cooldown - 0.1)
		"enemy_multiplier":
			game.enemy_multiplier += 1
			
func _error(message = "You don't have enough money!"):
	SoundManager.play_sound("NotificationError")
	var error = object.create("error_notification")
	error.error_message = message
	error._update()

func _update_upgrades_state(item):
	if game.upgrades.has(item.id):
		item.level = game.upgrades[item.id]
	else:
		game.upgrades[item.id] = item.level
