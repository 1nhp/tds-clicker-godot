extends Node

var coins: float = 0
var income: int = 0

var total_droopers: int = 0
var drooper_cooldown: float = 1
var enemy_multiplier: float = 1
var enemies_killed: float = 0
var autoclickers: float = 0
var first_time: bool = true

@export var total_income: float
@export var coins_earned: float

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
@export var total_income_counter: Label
@export var total_income_counter2: Label
@export var total_income_timer: Timer


@export var droopers_counter: Label
@export var droopers_counter2: Label
@export var coin_icon: TextureRect
@export var drooper_icon: TextureRect
@export var screen_blur_canvas: ColorRect
@export var screen_blur_anim: Node
@export var store_button: Node
@export var settings_button: Node
@export var changelog_button: Node
@export var stats_button: Node

@onready var enemy = get_tree().get_first_node_in_group("enemy")
@export var ui_container: Node

var spawnCoins = SpawnCoins.new()
var menuController = MenuController.new()

func _ready():
	Globals._get_game()
	SavingSystem.load_data()
	AudioServer.set_bus_volume_db(1, linear_to_db(settings.get("musicvolume", 0.5)))
	AudioServer.set_bus_volume_db(2, linear_to_db(settings.get("soundvolume", 1)))
	
	if first_time:
		object.create("changelog", Vector2.ZERO, "/root/game/UI")
		menuController.open_menu(
			ui_container.get_node("Changelog"),
			ui_container.get_node("Changelog/AnimationPlayer")
		)
		first_time = false
		SavingSystem.save_data()
		
	update_coin_count()
	start_loops()
	create_autoclicker()
	playtime()
	var store = object.create("store", Vector2.ZERO, "/root/game/UI")
	store.visible = false
	enemy._update_enemy(enemy_name)

func start_loops():
	income_loop()
	savedata_loop()
	
func savedata_loop():
	while true:	
		await get_tree().create_timer(4).timeout
		SavingSystem.save_data()

func update_total_income():
	total_income_counter.text = "+" + str(NumFormat.format_number(total_income))
	total_income_counter2.text = "+" + str(NumFormat.format_number(total_income))

func _on_total_income_timer_timeout() -> void:
	total_income = 0

func update_coin_count():
	update_total_income()
	coin_counter.text = NumFormat.format_number(coins)
	coin_counter2.text = NumFormat.format_number(coins)
	droopers_counter.text = NumFormat.format_number(total_droopers)
	droopers_counter2.text = NumFormat.format_number(total_droopers)
	income_counter.text = NumFormat.format_number(income)
	income_counter2.text = NumFormat.format_number(income)

	
	if settings["ui_animations"]:
		var tween = create_tween()

		tween.tween_property(coin_counter3, "scale", Vector2(1.2, 1.2), 0.05)
		tween.parallel().tween_property(coin_icon, "scale", Vector2(1.2, 1.2), 0.05)
		tween.tween_interval(0.1)
		tween.tween_property(coin_counter3, "scale", Vector2(1, 1), 0.05)
		tween.parallel().tween_property(coin_icon, "scale", Vector2(1, 1), 0.05)
	
func _on_enemy_enemy_clicked() -> void:
	SoundManager.play_sound("Coin", randf_range(0.8, 1.3))
	coins += enemy.coin_award * enemy_multiplier
	total_income += enemy.coin_award * enemy_multiplier
	coins_earned += enemy.coin_award * enemy_multiplier
	enemies_killed += 1
	update_coin_count()

func _on_store_button_clicked(_button: FancyButton) -> void: 
	menuController.open_menu(
		ui_container.get_node("Store"),
		ui_container.get_node("Store/WindowAnim")
	)
	SoundManager.play_sound("StoreOpen")
func _on_settings_button_clicked(_button: FancyButton) -> void: 
	object.create("settings", Vector2.ZERO, "/root/game/UI")
	menuController.open_menu(
		ui_container.get_node("Settings"),
		ui_container.get_node("Settings/AnimationPlayer")
	)
func _on_changelog_button_pressed() -> void:
	object.create("changelog", Vector2.ZERO, "/root/game/UI")
	menuController.open_menu(
		ui_container.get_node("Changelog"),
		ui_container.get_node("Changelog/AnimationPlayer")
	)
func _on_stats_button_pressed() -> void:
	object.create("stats", Vector2.ZERO, "/root/game/UI")
	menuController.open_menu(
		ui_container.get_node("Stats"),
		ui_container.get_node("Stats/AnimationPlayer")
	)

func set_blur(state: bool) -> void:
	if not settings.get("blur_bg", true):
		screen_blur_canvas.visible = false
		return

	if state:
		screen_blur_anim.play("blur")
	else:
		screen_blur_anim.play_backwards("blur")
		
# Drooper logic
func income_loop():
	while true:
		await get_tree().create_timer(drooper_cooldown).timeout
		
		if income > 0:
			coins += income
			coins_earned += income
			total_income += income
			
			spawnCoins.spawn(income, settings["coin_particles"])
			
			if settings["ui_animations"]:
				create_tween().tween_property(drooper_icon, "scale", Vector2(1.2, 1.2), 0.05)
				create_tween().tween_property(drooper_icon, "modulate", Color(0.0, 0.922, 0.0, 1.0), 0.1)	
				await get_tree().create_timer(0.2).timeout	
				create_tween().tween_property(drooper_icon, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.1)		
				create_tween().tween_property(drooper_icon, "scale", Vector2(1, 1), 0.05)
			
			SoundManager.play_sound("Coin2", randf_range(0.8, 1.3))
			
func create_autoclicker(amount = autoclickers):
	for i in range(amount):
		await get_tree().create_timer(0.05).timeout
		var autoclicker = object.create("autoclicker", Vector2.ZERO, "/root/game/FG/Control/AutoClickerGrid")
		if i >= 10:
			autoclicker.visible = false

var total_playtime_seconds : float = 0.0

func playtime():
	while true:
		await get_tree().create_timer(1).timeout
		total_playtime_seconds += 1

func get_playtime_formatted() -> String:
	var hours = int(total_playtime_seconds) / 3600
	var minutes = (int(total_playtime_seconds) % 3600) / 60
	return "%02d hours, %02d minutes" % [hours, minutes]
