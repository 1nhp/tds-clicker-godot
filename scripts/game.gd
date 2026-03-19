extends Node

var version = "1.1 Beta"

var coins: int = 0
var income: int = 0

var droopers = {
	"Rusty Drooper": 0,
	"Plastic Drooper": 0
}
var total_droopers: int = 0
var drooper_cooldown: float = 1
var enemy_multiplier: float = 1
var coins_display = coins

var enemies = {
	"Abnormal": false,
	"Speedy": false,
	"Heavy": false,
	"Normal Boss": false,
	"Hidden": false,
	"Elite Abnormal": false,
	"Molten": false,
	"Corpse": false,
	"Molten Golem": false,
	"Elite Hazmat": false,
	"Hidden Boss": false,
	"Molten Necromancer": false,
	"Elite Boomer": false,
	"Molten Hound": false,	
	"Molten Mech": false,		
}

var upgrades = {}
var enemy_name = "Normal"

var settings = {
	"blur_bg": true,
	"coin_particles": 100,
	"enemy_animations": true,
	"ui_animations": true,
	"musicvolume": 1.0,
	"soundvolume": 1.0,
}

@onready var coin_counter = $HUD/TL/CoinCounter/Counter/Label
@onready var coin_counter2 = $HUD/TL/CoinCounter/Counter/Label2
@onready var coin_counter3 = $HUD/TL/CoinCounter/Counter
@onready var income_counter = $HUD/TL/Income/Counter/Label
@onready var income_counter2 = $HUD/TL/Income/Counter/Label2

@onready var droopers_counter = $HUD/TL/DroopersCounter/Counter/Label
@onready var droopers_counter2 = $HUD/TL/DroopersCounter/Counter/Label2
@onready var coin_icon = $HUD/TL/CoinCounter/coin_icon
@onready var drooper_icon = $HUD/TL/DroopersCounter/drooper_icon
@onready var screen_blur = get_tree().get_first_node_in_group("screen_blur")
@onready var blur_canvas = get_tree().get_first_node_in_group("blur_canvas")

func _ready():
	SavingSystem.load_data()
	AudioServer.set_bus_volume_db(1, linear_to_db(settings["musicvolume"]))
	AudioServer.set_bus_volume_db(2, linear_to_db(settings["soundvolume"]))
	
	_update_coin_count()
	income_loop()
	savedata_loop()
	get_tree().get_first_node_in_group("enemy")._update_enemy(enemy_name)
	
	
func savedata_loop():
	while true:	
		await get_tree().create_timer(4).timeout
		SavingSystem.save_data()

func _update_coin_count():
	coins_display = NumFormat.format_number(coins)
	coin_counter.text = str(coins_display)
	coin_counter2.text = str(coins_display)
	droopers_counter.text = str(total_droopers)
	droopers_counter2.text = str(total_droopers)
	income_counter.text = str(income)
	income_counter2.text = str(income)
	
	if settings["ui_animations"]:
		var tween = create_tween()

		tween.tween_property(coin_counter3, "scale", Vector2(1.2, 1.2), 0.05)
		tween.parallel().tween_property(coin_icon, "scale", Vector2(1.2, 1.2), 0.05)

		tween.tween_interval(0.1)

		tween.tween_property(coin_counter3, "scale", Vector2(1, 1), 0.05)
		tween.parallel().tween_property(coin_icon, "scale", Vector2(1, 1), 0.05)
	
	
func _on_enemy_enemy_clicked() -> void:
	SoundManager.play_sound("Coin", randf_range(0.8, 1.3))
	coins += get_tree().get_first_node_in_group("enemy").coin_award * enemy_multiplier
	_update_coin_count()

func _on_store_button_pressed() -> void:
	object.create("ui_store", Vector2.ZERO, "/root/game/HUD")
	_blur_screen()

func _on_settings_button_pressed() -> void:
	object.create("ui_settings", Vector2.ZERO, "/root/game/HUD")
	_blur_screen()

func _blur_screen(transition = true):
	if settings["blur_bg"] == true:
		if transition:
			screen_blur.play("blur")
		else:
			screen_blur.play_backwards("blur")
	else:
		blur_canvas.visible = false
			
# Drooper logic
func income_loop():
	while true:
		await get_tree().create_timer(drooper_cooldown).timeout
		
		if income > 0:
			coins += income
			
			var max_effects = min(income, settings["coin_particles"])

			for i in range(max_effects):
				var offset_x = randi_range(-90, 90)
				var offset_y = randi_range(-90, 90)

				object.create(
					"coin_effect",
					Vector2(30 + offset_x, 30 + offset_y)
				)	
				
			if settings["ui_animations"]:
				create_tween().tween_property(drooper_icon, "scale", Vector2(1.2, 1.2), 0.05)
				create_tween().tween_property(drooper_icon, "modulate", Color(0.0, 0.922, 0.0, 1.0), 0.1)	
				await get_tree().create_timer(0.2).timeout	
				create_tween().tween_property(drooper_icon, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.1)		
				create_tween().tween_property(drooper_icon, "scale", Vector2(1, 1), 0.05)

			
			SoundManager.play_sound("Coin2", randf_range(0.8, 1.3))
			#_update_coin_count()
