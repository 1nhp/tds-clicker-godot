extends Node

var coins = 0
var income = 0

var droopers = {
	"Rusty Drooper": 0,
	"Plastic Drooper": 0
}
var total_droopers = 0
var enemies = {
	"Abnormal": false,
	"Speedy": false
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

func _ready():
	print(droopers)
	_update_coin_count()
	income_loop()
	
func _update_coin_count():
	coin_counter.text = str(coins)
	coin_counter2.text = str(coins)
	droopers_counter.text = str(total_droopers)
	droopers_counter2.text = str(total_droopers)
	income_counter.text = str(income)
	income_counter2.text = str(income)

	var tween = create_tween()

	tween.tween_property(coin_counter3, "scale", Vector2(1.2, 1.2), 0.05)
	tween.parallel().tween_property(coin_icon, "scale", Vector2(1.2, 1.2), 0.05)

	tween.tween_interval(0.1)

	tween.tween_property(coin_counter3, "scale", Vector2(1, 1), 0.05)
	tween.parallel().tween_property(coin_icon, "scale", Vector2(1, 1), 0.05)
	

	
func _on_enemy_enemy_clicked() -> void:
	SoundManager.play_sound("Coin", randf_range(0.8, 1.3))
	coins += get_tree().get_first_node_in_group("enemy").coin_award
	_update_coin_count()

func _on_store_button_pressed() -> void:
	object.create("ui_store")
	get_tree().get_first_node_in_group("screen_blur").play("blur")

# Drooper logic
func income_loop():
	while true:
		await get_tree().create_timer(1).timeout
		
		if income > 0:
			coins += income
			
			var max_effects = min(income, 40)

			for i in range(max_effects):
				var offset_x = randi_range(-90, 90)
				var offset_y = randi_range(-90, 90)

				object.create(
					"coin_effect",
					Vector2(30 + offset_x, 30 + offset_y)
				)	
			create_tween().tween_property(drooper_icon, "scale", Vector2(1.2, 1.2), 0.05)
			create_tween().tween_property(drooper_icon, "modulate", Color(0.0, 0.922, 0.0, 1.0), 0.1)	
			await get_tree().create_timer(0.2).timeout	
			create_tween().tween_property(drooper_icon, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.1)		
			create_tween().tween_property(drooper_icon, "scale", Vector2(1, 1), 0.05)

			
			SoundManager.play_sound("Coin", randf_range(0.8, 1.3))
			_update_coin_count()
