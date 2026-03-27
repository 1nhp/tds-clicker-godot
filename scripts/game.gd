extends Node

var coins: float = 0
var income: int = 0

var total_droopers: int = 0
var drooper_cooldown: float = 1
var enemy_multiplier: float = 1

var enemies = {}
var upgrades = {}
var droopers = {}
var settings = {
	"blur_bg": true,
	"coin_particles": 100,
	"enemy_animations": true,
	"ui_animations": true,
	"musicvolume": 1.0,
	"soundvolume": 1.0,
	"dropdown_selection": {
		"coin_particles": 1,
		"language": 1,
	}
}

var enemy_name = "Normal"

@export var coin_counter: Label
@export var coin_counter2: Label
@export var coin_counter3: Control
@export var income_counter: Label
@export var income_counter2: Label

@export var droopers_counter: Label
@export var droopers_counter2: Label
@export var coin_icon: TextureRect
@export var drooper_icon: TextureRect
@export var screen_blur_canvas: ColorRect
@export var screen_blur_anim: Node
@export var store_button: Node
@export var settings_button: Node

var spawnCoins = SpawnCoins.new()

func _ready():
	
	SavingSystem.load_data()
	Globals._get_game()
	AudioServer.set_bus_volume_db(1, linear_to_db(settings.get("musicvolume", 0.5)))
	AudioServer.set_bus_volume_db(2, linear_to_db(settings.get("soundvolume", 1)))
	
	update_coin_count()
	start_loops()
	get_tree().get_first_node_in_group("enemy")._update_enemy(enemy_name)

func start_loops():
	income_loop()
	savedata_loop()
	
func savedata_loop():
	while true:	
		await get_tree().create_timer(4).timeout
		SavingSystem.save_data()

func update_coin_count():
	coin_counter.text = NumFormat.format_number(coins)
	coin_counter2.text = NumFormat.format_number(coins)
	droopers_counter.text = str(total_droopers)
	droopers_counter2.text = str(total_droopers)
	income_counter.text = NumFormat.format_number(income)
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
	update_coin_count()

enum actions {SHOW, CLOSE}
signal MenuClosing
signal MenuOpening

func menu(action = actions.SHOW, name = "ui_store", closingvar = false, anim_player = Node, root = self):
	var closing = closingvar
	
	if action == actions.SHOW:
		object.create(name, Vector2.ZERO, "/root/game/UI")
		blur_screen()
		print_debug("Opening menu")
		emit_signal("MenuOpening")

	if action == actions.CLOSE:
		blur_screen(false)
		print_debug("Closing menu")
		closing = true
		print("aaa" + str(anim_player))
		if settings["ui_animations"]:
			anim_player.play_backwards("anim")
		else:
			root.queue_free()
		emit_signal("MenuClosing")
	return closing


func _on_store_button_clicked(_button: FancyButton) -> void: menu(actions.SHOW, "ui_store")
func _on_settings_button_clicked(_button: FancyButton) -> void: menu(actions.SHOW, "ui_settings")

func blur_screen(transition = true):
	if settings["blur_bg"] == true:
		if transition:
			screen_blur_anim.play("blur")
		else:
			screen_blur_anim.play_backwards("blur")
	else:
		screen_blur_canvas.visible = false
		
# Drooper logic
func income_loop():
	while true:
		await get_tree().create_timer(drooper_cooldown).timeout
		
		if income > 0:
			coins += income
			
			spawnCoins.spawn(income, settings["coin_particles"])
			
			if settings["ui_animations"]:
				create_tween().tween_property(drooper_icon, "scale", Vector2(1.2, 1.2), 0.05)
				create_tween().tween_property(drooper_icon, "modulate", Color(0.0, 0.922, 0.0, 1.0), 0.1)	
				await get_tree().create_timer(0.2).timeout	
				create_tween().tween_property(drooper_icon, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.1)		
				create_tween().tween_property(drooper_icon, "scale", Vector2(1, 1), 0.05)
			
			SoundManager.play_sound("Coin2", randf_range(0.8, 1.3))
