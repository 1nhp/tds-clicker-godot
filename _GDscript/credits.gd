extends Node

var closing: bool
@export var anim_player: Node
@export var credits_root: Node

func _on_close_button_pressed() -> void:
	Globals.game.menuController.close_menu(credits_root, anim_player, "anim_closing", true, false, false)
