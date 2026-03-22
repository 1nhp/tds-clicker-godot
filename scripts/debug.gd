extends Node

func _unhandled_input(_event: InputEvent) -> void:
	if OS.is_debug_build():
		if Input.is_key_pressed(KEY_R):
			print("Scene reloaded")
			SceneManager.reload()
		if Input.is_key_pressed(KEY_C):
			var game = get_tree().get_first_node_in_group("game")
			game.coins += 10000000000000000000000000000000000
			game.update_coin_count()
			print_debug("gave player coins")
		if Input.is_key_pressed(KEY_T):	
			TranslationServer.set_locale("ru")
			print_debug("Language changed")
			
func _ready() -> void:
	if not OS.is_debug_build():
		DebugInfo.queue_free()
