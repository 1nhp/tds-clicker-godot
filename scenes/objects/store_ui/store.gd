extends Control

var closing := false

@onready var game = get_tree().get_first_node_in_group("game")
@onready var enemy = get_tree().get_first_node_in_group("enemy")

# Containers
@onready var enemy_container = $Window/EnemiesTab/EnemyList/BoxContainer/GridContainer
@onready var drooper_container = $Window/DroopersTab/DrooperList/BoxContainer/GridContainer
@onready var upgrade_container = $Window/UpgradesTab/UpgradeList/BoxContainer

# Enemy UI
@onready var enemy_name = $Window/EnemiesTab/EnemyContent/name
@onready var enemy_coin = $Window/EnemiesTab/EnemyContent/coinaward
@onready var enemy_image = $Window/EnemiesTab/EnemyContent/image
@onready var enemy_price = $Window/EnemiesTab/EnemyContent/price
@onready var enemy_buy = $Window/EnemiesTab/EnemyContent/buy

# Drooper UI
@onready var drooper_name = $Window/DroopersTab/DrooperContent/name
@onready var drooper_coin = $Window/DroopersTab/DrooperContent/coinaward
@onready var drooper_image = $Window/DroopersTab/DrooperContent/image
@onready var drooper_price = $Window/DroopersTab/DrooperContent/price
@onready var drooper_buy = $Window/DroopersTab/DrooperContent/buy

# Scenes
var store_button_scene = preload("res://scenes/objects/store_ui/store_select_button.tscn")
var upgrade_container_scene = preload("res://scenes/objects/error_notification/store_upgrade_container.tscn")

# Store data
var store_items = []

# Upgrade references
var upgrade_containers = {}
var upgrade_data = {}

# Selected item
var current_item

func _ready():
	$AnimationPlayer.play("slide")

	# Load items
	store_items += _load_store_items("res://assets/data/manifest/enemies")
	store_items += _load_store_items("res://assets/data/manifest/droopers")
	store_items += _load_store_items("res://assets/data/manifest/upgrades")

	# Populate store
	for item in store_items:
		match item.type:
			"Enemy":
				_create_button(item, enemy_container)
			"Drooper":
				_create_button(item, drooper_container)
			"Upgrade":
				_create_upgrade(item)

func _load_store_items(folder):
	var items = []
	var dir = DirAccess.open(folder)

	dir.list_dir_begin()
	var file = dir.get_next()

	while file != "":
		if file.ends_with(".tres"):
			var item = load(folder + "/" + file)
			items.append(item)
		file = dir.get_next()
	dir.list_dir_end()
	items.sort_custom(func(a,b): return a.price < b.price)

	return items

func _create_button(item, container):
	var button = store_button_scene.instantiate()
	container.add_child(button)
	button.icon = item.texture
	button.custom_minimum_size = Vector2(64,64)
	button.set_meta("item", item)
	button.clicked.connect(_on_item_clicked)

func _create_upgrade(item):
	var container = upgrade_container_scene.instantiate()
	upgrade_container.add_child(container)

	var buy_button = container.get_node("Control/buy")
	buy_button.set_meta("item", item)
	buy_button.clicked.connect(_on_upgrade_clicked)
	upgrade_containers[item.id] = container
	upgrade_data[item.id] = item

	if game.upgrades.has(item.id):
		item.level = game.upgrades[item.id]
	else:
		game.upgrades[item.id] = item.level
	container.custom_minimum_size = Vector2(50,75)

	_update_upgrade_container(container,item)

func _on_item_clicked(button):
	current_item = button.get_meta("item")
	_update_content(current_item)

func _update_content(item):
	match item.type:
		"Enemy":
			enemy_name.text = item.name
			enemy_coin.text = str(item.coin_award) + " per click"
			enemy_image.texture = item.texture
			enemy_price.text = "Price: " + str(item.price)
			_update_enemy_button()
		"Drooper":
			drooper_name.text = item.name
			drooper_coin.text = str(item.coin_award) + " per second"
			drooper_image.texture = item.texture
			drooper_price.text = "Price: " + str(item.price)

func _on_upgrade_clicked(button):
	var item = button.get_meta("item")
	_buy_upgrade(item, button)

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
	_update_upgrade_container(upgrade_containers[item.id],item)
	
func _apply_upgrade_effect(id):
	match id:
		"drooper_cooldown":
			game.drooper_cooldown = max(0.0,game.drooper_cooldown - 0.1)
		"enemy_multiplier":
			game.enemy_multiplier += 1

func _update_upgrade_container(container,item):
	var control = container.get_node("Control")
	control.get_node("upgrade_name").text = item.name
	var price = int(item.base_price * pow(item.price_multiplier,item.level))
	var display_price = NumFormat.format_number(price)
	
	control.get_node("upgrade_price").text = "Price: " + str(display_price)
	control.get_node("icon").texture = item.texture
	control.get_node("upgrade_description").text = item.description
	if item.id == "drooper_cooldown":
		control.get_node("variable").text = "Cooldown: " + str(game.drooper_cooldown)
	if item.id == "enemy_multiplier":
		control.get_node("variable").text = str(game.enemy_multiplier) + "x Mult"	
		control.get_node("variable").add_theme_color_override("font_color", Color(1.0, 0.0, 0.0, 1.0))

	control.get_node("buy").text = "Upgrade Level " + str(item.level)

func _update_enemy_button():
	if game.enemies.get(current_item.name,false):
		enemy_buy.text = "Change"
	else:
		enemy_buy.text = "Buy"


func _on_buy_clicked(button):
	object.create("coin_particles", Vector2(enemy_buy.global_position.x + 100, enemy_buy.global_position.y + 40))
	if game.coins < current_item.price:
		_error()
		return

	match current_item.type:
		"Enemy":
			_buy_enemy()
		"Drooper":
			_buy_drooper()

func _buy_enemy():
	if game.enemies.get(current_item.name,false):
		enemy._update_enemy(current_item.codename)
		game.enemy_name = current_item.codename
		return

	game.coins -= current_item.price
	game.enemies[current_item.name] = true
	game.enemy_name = current_item.id
	enemy._update_enemy(current_item.id)
	SoundManager.play_sound("Upgrade")
	game._update_coin_count()
	_update_enemy_button()

func _buy_drooper():
	game.coins -= current_item.price
	game.total_droopers += 1
	game.droopers[current_item.name] = game.droopers.get(current_item.name,0) + 1
	game.income += current_item.coin_award
	SoundManager.play_sound("Upgrade")
	game._update_coin_count()

func _error(message = "You don't have enough money!"):
	SoundManager.play_sound("NotificationError")
	var error = object.create("error_notification")
	error.error_message = message
	error._update()


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "slide" and closing:
		queue_free()

func _switch_tab(tab):
	for t in [$Window/DroopersTab,$Window/EnemiesTab,$Window/UpgradesTab]:
		t.visible = false
	tab.visible = true


func _on_enemies_button_clicked(button): _switch_tab($Window/EnemiesTab)
func _on_droopers_button_clicked(button): _switch_tab($Window/DroopersTab)
func _on_upgrades_button_clicked(button): _switch_tab($Window/UpgradesTab)

func _on_close_button_clicked(button):
	$AnimationPlayer.play_backwards("slide")
	closing = true

	var store_button = get_tree().get_first_node_in_group("store_button")
	store_button.disabled = false
	var screen_blur = get_tree().get_first_node_in_group("screen_blur")
	screen_blur.play_backwards("blur")

	$Window.mouse_filter = Control.MOUSE_FILTER_IGNORE
