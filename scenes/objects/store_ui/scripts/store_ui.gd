extends Node

var closing := false
@onready var enemy = get_tree().get_first_node_in_group("enemy")
@onready var anim_player = get_tree().get_first_node_in_group("AnimationPlayer")
@onready var store_root = get_tree().get_first_node_in_group("store_root")
@onready var StoreManager = get_tree().get_first_node_in_group("StoreManager")
@onready var StoreLogic = get_tree().get_first_node_in_group("StoreLogic")

# Containers
@onready var enemy_container = get_tree().get_first_node_in_group("EnemyContainer")
@onready var drooper_container = get_tree().get_first_node_in_group("DrooperContainer")
@onready var upgrade_container = get_tree().get_first_node_in_group("UpgradeContainer")
@onready var enemy_content_container = get_tree().get_first_node_in_group("EnemyContentContainer")
@onready var drooper_content_container = get_tree().get_first_node_in_group("DrooperContentContainer")
# Tabs
@onready var EnemiesTab = get_tree().get_first_node_in_group("EnemiesTab")
@onready var DroopersTab = get_tree().get_first_node_in_group("DroopersTab")
@onready var UpgradesTab = get_tree().get_first_node_in_group("UpgradesTab")

#
var store_button_scene = preload("res://scenes/objects/store_ui/store_select_button.tscn")
var upgrade_container_scene = preload("res://scenes/objects/error_notification/store_upgrade_container.tscn")

func _ready():
	get_tree().get_first_node_in_group("LoadingText").visible = true
	
	if StoreManager.game.settings["ui_animations"]:
		anim_player.play("slide")
		
	EnemiesTab.visible = false
	DroopersTab.visible = false
	UpgradesTab.visible = false

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
	StoreManager.upgrade_containers[item.id] = container
	StoreManager.upgrade_data[item.id] = item

	StoreLogic._update_upgrades_state(item)
	container.custom_minimum_size = Vector2(50,75)
	_update_upgrade_container(container,item)

func _on_item_clicked(button):
	StoreManager.current_item = button.get_meta("item")
	_update_content(StoreManager.current_item)

func _fill_content(container, item, rate_text):
	container.get_node("name").text = item.name
	container.get_node("coinaward").text = rate_text
	container.get_node("image").texture = item.texture
	var display_item_price = NumFormat.format_number(item.price)
	container.get_node("price").text = "Price: " + str(display_item_price)

func _update_content(item):
	match item.type:
		"Enemy":
			_fill_content(enemy_content_container,item,str(item.coin_award) + " per click")
			_update_enemy_button()
		"Drooper":
			_fill_content(drooper_content_container,item,str(item.coin_award) + " per second")
			
func _on_upgrade_clicked(button):
	var item = button.get_meta("item")
	StoreLogic._buy_upgrade(item, button)

func _update_upgrade_container(container,item):
	var control = container.get_node("Control")
	var price = int(item.base_price * pow(item.price_multiplier,item.level))
	var display_price = NumFormat.format_number(price)
	
	control.get_node("upgrade_name").text = item.name
	control.get_node("upgrade_price").text = "Price: " + str(display_price)
	control.get_node("icon").texture = item.texture
	control.get_node("upgrade_description").text = item.description
	
	var text = item.get_display_text(StoreManager.game)
	control.get_node("variable").text = text
	control.get_node("variable").add_theme_color_override("font_color", item.text_color)
	control.get_node("buy").text = "Upgrade Level " + str(item.level)

func _update_enemy_button():
	if StoreManager.game.enemies.get(StoreManager.current_item.name,false):
		enemy_content_container.get_node("buy").text = "Change"
	else:
		enemy_content_container.get_node("buy").text = "Buy"

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "slide" and closing:
		await get_tree().process_frame
		store_root.queue_free()

func _switch_tab(tab):
	if 	get_tree().get_first_node_in_group("LoadingText").visible == false:
		for t in [DroopersTab,EnemiesTab,UpgradesTab]:
			t.visible = false
		tab.visible = true

func _on_enemies_button_clicked(button): _switch_tab(EnemiesTab)
func _on_droopers_button_clicked(button): _switch_tab(DroopersTab)
func _on_upgrades_button_clicked(button): _switch_tab(UpgradesTab)

func _on_close_button_clicked(button):
	if StoreManager.game.settings["ui_animations"]:
		anim_player.play_backwards("slide")
		closing = true
	else:
		store_root.queue_free()
		
	var store_button = get_tree().get_first_node_in_group("store_button")
	store_button.disabled = false
	StoreManager.game._blur_screen(false)


func _on_store_manager_finished_loading() -> void:
	for item in StoreManager.store_items:
		match item.type:
			"Enemy":_create_button(item, enemy_container)
			"Drooper":_create_button(item, drooper_container)
			"Upgrade":_create_upgrade(item)
		await get_tree().process_frame

	print("finished!")
	EnemiesTab.visible = true
	get_tree().get_first_node_in_group("LoadingText").visible = false
