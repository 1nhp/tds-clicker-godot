extends Control

var closing: bool = false

var item_name = "Rusty Drooper"
var item_price = 100
var item_coinaward = 1
var item_preview = load("res://assets/sprites/droopers/drooper_1_preview.png")
var item_type = "Drooper"
var game = []

@export var item_data: EnemyData
@export var paths: PathData

func _on_enemy_button_clicked(button: FancyButton) -> void:
	var key = button.get_meta("enemy_key")
	if paths and paths.ENEMIES.has(key):
		_update_content(paths.ENEMIES[key]["path"])

func _on_drooper_button_clicked(button: FancyButton) -> void:
	var key = button.get_meta("drooper_key")
	if paths and paths.DROOPERS.has(key):
		_update_content(paths.DROOPERS[key]["path"])


func _ready() -> void:
	game = get_tree().get_first_node_in_group("game")
	$AnimationPlayer.play("slide")
	_update_content()
	
func _on_close_button_clicked(button: FancyButton):
	$AnimationPlayer.play_backwards("slide")
	closing = true
	var store_button = get_tree().get_first_node_in_group("store_button")
	if store_button: store_button.disabled = false
	var screen_blur = get_tree().get_first_node_in_group("screen_blur")
	if screen_blur: screen_blur.play_backwards("blur")
	$Window.mouse_filter = Control.MOUSE_FILTER_IGNORE	
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "slide" and closing:
		queue_free()

func _update_content(data = "res://assets/data/manifest/enemies/abnormal.tres"):
	item_data = load(data)
	item_name = item_data.name
	item_coinaward = item_data.coin_award
	item_preview = item_data.texture
	item_price = item_data.price
	item_type = item_data.type
	
	if item_type == "Drooper":
		$Window/DroopersTab/DrooperContent/name.text = item_name
		$Window/DroopersTab/DrooperContent/coinaward.text = str(item_coinaward) + " per second"
		$Window/DroopersTab/DrooperContent/image.texture = item_preview
		$Window/DroopersTab/DrooperContent/price.text = "Price: " + str(item_price) + " Coins"
	if item_type == "Enemy":
		$Window/EnemiesTab/EnemyContent/name.text = item_name
		$Window/EnemiesTab/EnemyContent/coinaward.text = str(item_coinaward) + " per click"
		$Window/EnemiesTab/EnemyContent/image.texture = item_preview
		$Window/EnemiesTab/EnemyContent/price.text = "Price: " + str(item_price) + " Coins"		

func _error(message = "You don't have enough money to buy this!"):
		SoundManager.play_sound("NotificationError")
		var error = object.create("error_notification")	
		error.error_message = message
		error._update()
func _on_buy_clicked(button: FancyButton) -> void:
	if item_type == "Drooper" and game.coins < item_price:
		_error()
	elif item_type == "Enemy" and (game.coins < item_price):
		_error()
	elif game.enemies.get(item_name, false):
		_error("You already own this enemy!")
	else:
		SoundManager.play_sound("Upgrade")
		game.coins -= item_price
		object.create("coin_partices", Vector2($Window/DroopersTab/DrooperContent/buy.global_position.x + 100, $Window/EnemiesTab/EnemyContent/buy.global_position.y + 20))
		if item_type == "Drooper":
			game.total_droopers += 1
			game.droopers[item_name] += 1
			game.income += item_coinaward
			game._update_coin_count()
		if item_type == "Enemy":
			var enemy = get_tree().get_first_node_in_group("enemy")._update_enemy(item_data)
			game.enemies[item_name] = true
			game._update_coin_count()
			
func _on_enemies_button_clicked(button: FancyButton) -> void:
	$Window/DroopersTab.visible = false
	$Window/EnemiesTab.visible = true
	$Window/EnemiesTab/EnemyContent.visible = true
	$Window/EnemiesTab/EnemyList.visible = true
	
	_update_content()	
func _on_droopers_button_clicked(button: FancyButton) -> void:
	$Window/DroopersTab.visible = true
	$Window/EnemiesTab.visible = false
