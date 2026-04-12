extends Node

var closing: bool
@export var anim_player: Node
@export var credits_root: Node

func _ready() -> void:
	if Globals.game.settings["ui_animations"]:
		anim_player.play("anim")

func _on_close_button_clicked(_button: FancyButton):
	closing = Globals.game.menu(false, Globals.game.actions.CLOSE, "ui_credits", closing, anim_player, credits_root, "anim_closing", false)

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "anim_closing":
		if closing: credits_root.queue_free()
