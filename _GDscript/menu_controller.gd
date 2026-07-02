extends Node
class_name MenuController

signal menu_opening
signal menu_closing

func open_menu(menu_node: Control, anim_player: AnimationPlayer, blur = true) -> void:
	if blur: Globals.game.set_blur(true)
	menu_node.visible = true
	if Globals.game.settings.get("ui_animations", false) and anim_player:	
		anim_player.play("anim")
	menu_opening.emit()
	
func close_menu(menu_node: Control, anim_player: AnimationPlayer, animation := "anim", destroy := false, backwards = false, blur = true) -> void:
	if blur: Globals.game.set_blur(false)
	var use_anim: bool = Globals.game.settings.get("ui_animations", false) and anim_player != null

	if use_anim:
		if backwards:
			anim_player.play_backwards(animation)
		else:
			anim_player.play(animation)

		await anim_player.animation_finished

	for child in menu_node.get_children():
		if child is AnimationPlayer:
			child.play("RESET")

	menu_node.visible = false
	menu_closing.emit()

	if destroy:
		menu_node.queue_free()
