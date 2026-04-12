extends Node
# Closing variable
var closing = false

# Node references
@export var loading_text: Node
@export var anim_player: Node
@export var list_anim_player: Node
@export var content_anim_player: Node
@export var tab_buttons_anim_player: Node
@export var store_header_anim: Node

@export var store_window: Node

@export var store_root: Node
@export var StoreManager: Node
@export var StoreLogic: Node

# Containers
@export var enemy_container: Node
@export var drooper_container: Node
@export var upgrade_container: Node
@export var enemy_content_container: Node
@export var drooper_content_container: Node

# Tabs
@export var EnemiesTab: Node
@export var DroopersTab: Node
@export var UpgradesTab: Node

# Object scene references
var store_button_scene = preload("res://scenes/objects/store_ui/store_select_button.tscn")
var upgrade_container_scene = preload("res://scenes/objects/store_ui/store_upgrade_container.tscn")

func play_ui_anim(anim = "default"):
	if StoreManager.game.settings["ui_animations"]:
		match anim:
			"default":
					list_anim_player.stop()
					content_anim_player.stop()
					content_anim_player.play("ContentAnim/content_anim")
					list_anim_player.play("ListAnim/list_fade")
			
			"content": 
				content_anim_player.stop()
				content_anim_player.play("ContentAnim/content_anim")	
			"header":
				store_header_anim.play("StoreHeaderAnim/anim")

# Initialization function
func _ready():
	
	# Show loading text and connect MenuClosing Function
	loading_text.visible = true
	Globals.game.MenuClosing.connect(_on_menu_closing)
	
	# If ui animations are turned on play opening animation
	if StoreManager.game.settings["ui_animations"]:
		anim_player.play("anim")
		play_ui_anim("header")
		
	# Set all tab visibility to false
	EnemiesTab.visible = false
	DroopersTab.visible = false
	UpgradesTab.visible = false

# Enable store button
func _on_menu_closing():
	Globals.game.store_button.disabled = false

# This function will create store selection button for
# Enemies and drooper list
func create_button(item, container):
	# Create button
	var button = store_button_scene.instantiate()
	container.call_deferred("add_child", button) 
	# Set button icon
	button.icon = item.texture
	
	# Set minimum size to 64x64 to fix overlapping
	# Then set meta to the item variable which is
	# an Resource reference
	button.custom_minimum_size = Vector2(64,64)
	button.set_meta("item", item)
	button.clicked.connect(_on_item_clicked)

# This function creates upgrade container for upgrades
# tab and sets the item meta like the previous function
func create_upgrade(item):
	# Create container
	var container = upgrade_container_scene.instantiate()
	upgrade_container.add_child(container)
	
	# Get buy button then set its meta to item
	var buy_button = container.get_node("Control/buy")
	buy_button.set_meta("item", item)
	buy_button.clicked.connect(on_upgrade_clicked)
	
	#Set upgrade_container reference
	StoreManager.upgrade_containers[item.id] = container
	StoreManager.upgrade_data[item.id] = item
	
	# Update item states
	# FIXME: tight coupling mind you!
	StoreLogic.update_item_state(item)
	
	container.custom_minimum_size = Vector2(50,75)
	update_upgrade_container(container,item)

func _on_item_clicked(button):
	StoreManager.current_item = button.get_meta("item")
	update_content(StoreManager.current_item)
	play_ui_anim("content")
				
func _on_animation_player_animation_finished(anim_name):
	if anim_name == "anim":
		if closing: store_root.queue_free()
	
func fill_content(container, item, rate_text):
	container.get_node("name").text = item.name
	container.get_node("coinaward").text = rate_text
	container.get_node("image").texture = item.texture
	container.visible = true
	
	if item.type == "Drooper":
		if StoreManager.game.droopers.has(item.id):
			item.price = StoreManager.game.droopers[item.id]["price"]
	
	var display_item_price = NumFormat.format_number(item.price)
	container.get_node("price").text = tr("price") + str(display_item_price)

	
func update_content(item):
	match item.type:
		"Enemy":
			fill_content(enemy_content_container,item,str(NumFormat.format_number(item.coin_award)) + " " + tr("per_click"))
			update_enemy_button()
		"Drooper":
			fill_content(drooper_content_container,item,str(item.coin_award) + " " + tr("per_second"))
			
func on_upgrade_clicked(button):
	var item = button.get_meta("item")
	StoreLogic.buy_upgrade(item, button)

func update_upgrade_container(container,item):
	var control = container.get_node("Control")
	var price = float(item.base_price * pow(item.price_multiplier,item.level))
	var display_price = NumFormat.format_number(price)
	
	control.get_node("upgrade_name").text = tr(item.upgrade_name_key)
	control.get_node("upgrade_price").text = tr("price") + str(display_price)
	control.get_node("icon").texture = item.texture
	control.get_node("upgrade_description").text = tr(item.description_key)
	
	var text = item.get_display_text(StoreManager.game)
	control.get_node("variable").text = text
	control.get_node("variable").add_theme_color_override("font_color", item.text_color)
	control.get_node("buy").text = tr("upgrade_btn") + str(item.level)

func update_enemy_button():
	if StoreManager.game.enemies.get(StoreManager.current_item.id,false):
		enemy_content_container.get_node("buy").text = tr("enemy_change_btn")
	else:
		enemy_content_container.get_node("buy").text = tr("buy_btn")
		
func switch_tab(tab):
	play_ui_anim("default")

	for t in [DroopersTab,EnemiesTab,UpgradesTab]:
		t.visible = false
	tab.visible = true


func _on_enemies_button_clicked(_button): switch_tab(EnemiesTab)
func _on_droopers_button_clicked(_button): switch_tab(DroopersTab)
func _on_upgrades_button_clicked(_button): switch_tab(UpgradesTab)

func _on_close_button_clicked(_button):
	closing = Globals.game.menu(true, Globals.game.actions.CLOSE, "ui_store", closing, anim_player, store_root)

func _on_store_manager_finished_loading() -> void:
	for item in StoreManager.store_items:
		match item.type:
			"Enemy":create_button(item, enemy_container)
			"Drooper":create_button(item, drooper_container)
			"Upgrade":create_upgrade(item)
		await get_tree().process_frame

	SoundManager.play_sound("StoreOpen")
	EnemiesTab.visible = true
	play_ui_anim()

	if StoreManager.game.settings["ui_animations"]:
		tab_buttons_anim_player.play("TabButtons/tab_buttons_fade")
	else:
		store_root.get_node("Window/Buttons/EnemiesButton").modulate.a = 1
		store_root.get_node("Window/Buttons/DroopersButton").modulate.a = 1
		store_root.get_node("Window/Buttons/UpgradesButton").modulate.a = 1

	loading_text.visible = false

func _on_store_logic_update_enemy_button() -> void:
	update_enemy_button()
func _on_store_logic_update_upgrade_container(item):
	update_upgrade_container(StoreManager.upgrade_containers[item.id],item)
func _on_store_logic_update_drooper_content(item) -> void:
	fill_content(drooper_content_container,item,str(item.coin_award) + " " + tr("per_second"))
