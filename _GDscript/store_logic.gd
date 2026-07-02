extends Node

@onready var enemy = get_tree().get_first_node_in_group("enemy")
@onready var StoreUI = get_tree().get_first_node_in_group("StoreUI")
@onready var StoreManager = get_tree().get_first_node_in_group("StoreManager")

signal update_upgrade_container
signal update_enemy_button
signal update_drooper_content

func transaction(price, container = StoreUI.drooper_content_container):
	StoreManager.game.coins -= price
	SoundManager.play_sound("Upgrade")
	StoreManager.game.update_coin_count()
	object.create("coin_particles", Vector2(container.global_position.x + 100, container.global_position.y + 40))

func _on_buy_clicked(_button):
	if StoreManager.game.enemies.get(StoreManager.current_item.id,false):
		enemy._update_enemy(StoreManager.current_item.id)
		StoreManager.game.enemy_name = StoreManager.current_item.id
		return
	
	if StoreManager.game.coins < StoreManager.current_item.price:
		EventBus.show_notification("not_enough_coins", EventBus.types.ERROR)
		return

	match StoreManager.current_item.type:
		"Enemy":
			buy_enemy()
		"Drooper":
			buy_drooper()
		
func buy_enemy():
	StoreManager.game.enemies[StoreManager.current_item.id] = true
	StoreManager.game.enemy_name = StoreManager.current_item.id
	enemy._update_enemy(StoreManager.current_item.id)
	transaction(StoreManager.current_item.price, StoreUI.enemy_content_container.get_node("buy"))
	update_enemy_button.emit()

func buy_drooper():
	var item = StoreManager.current_item
	update_item_state(item)
	transaction(item.price, StoreUI.drooper_content_container.get_node("buy"))	
	
	item.price = StoreManager.game.droopers[item.id]["price"]
	
	print("Current item price: " + str(item.price))
	print("Game droopers data: " + str(StoreManager.game.droopers[item.id]))
	
	StoreManager.game.total_droopers += 1
	StoreManager.game.income += item.coin_award
	update_drooper_content.emit(item)
	
func buy_upgrade(item, button):
	var price = int(item.base_price * pow(item.price_multiplier,item.level))
	if StoreManager.game.coins < price:
		EventBus.show_notification("not_enough_coins", EventBus.types.ERROR)
		return
	
	if item.level >= item.max_level:
		EventBus.show_notification("upgrade_maxxed", EventBus.types.ERROR)
		return
			
	transaction(price, button)
	item.level += 1
	StoreManager.game.upgrades[item.id] = item.level
	
	apply_upgrade_effect(item.id)
	update_upgrade_container.emit(item)
	
func apply_upgrade_effect(id):
	match id:
		"drooper_cooldown":
			StoreManager.game.drooper_cooldown = max(0.0,StoreManager.game.drooper_cooldown - 0.1)
		"enemy_multiplier":
			StoreManager.game.enemy_multiplier += 1
		"autoclicker":
			StoreManager.game.autoclickers += 1
			object.create("autoclicker", Vector2.ZERO, "/root/game/FG/Control/AutoClickerGrid")

func update_item_state(item):
	match item.type:
		"Upgrade":
			if StoreManager.game.upgrades.has(item.id):
				item.level = StoreManager.game.upgrades[item.id]
			else:
				StoreManager.game.upgrades[item.id] = item.level
		"Drooper":
			if StoreManager.game.droopers.has(item.id):
				StoreManager.game.droopers[item.id]["bought"] += 1
				StoreManager.game.droopers[item.id]["price"] += item.price_addition
			else:
				StoreManager.game.droopers[item.id] = {
					"bought": 1,
					"price": item.price + item.price_addition
				}
