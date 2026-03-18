extends Node

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_R):
		print("Scene reloaded")
		SceneManager.reload()
	if Input.is_key_pressed(KEY_C):
		var game = get_tree().get_first_node_in_group("game")
		game.coins += 999999999999999
		game._update_coin_count()
		
#func _ready() -> void:
	#if not OS.is_debug_build():
		#DebugInfo.queue_free()
