extends Control

@export var enemies_killed_label: Label
@export var droopers_bought_label: Label
@export var upgrades_bought_label: Label
@export var enemies_bought_label: Label
@export var coins_earned_label: Label
@export var time_played_label: Label

@export var anim_player: AnimationPlayer

var upgrades = 0
var enemies = 0

func _ready():
	enemies = Globals.game.enemies.size()
	upgrades = Globals.game.upgrades.values().reduce(func(a, b): return a + b, 0)

	enemies_killed_label.text = tr("enemies_killed") + str(NumFormat.format_number(Globals.game.enemies_killed))
	droopers_bought_label.text = tr("droopers_bought") + str(NumFormat.format_number(Globals.game.total_droopers))
	upgrades_bought_label.text = tr("upgrades_bought") + str(NumFormat.format_number(upgrades))
	enemies_bought_label.text = tr("enemies_bought") + str(NumFormat.format_number(enemies))
	coins_earned_label.text = tr("coins_earned") + str(NumFormat.format_number(Globals.game.coins_earned))
	time_played_label.text = tr("time_played") + str((Globals.game.get_playtime_formatted()))

func _on_close_button_pressed() -> void:
	Globals.game.menuController.close_menu(self, anim_player, "anim", true, true, true)
	Globals.game.stats_button.disabled = false
