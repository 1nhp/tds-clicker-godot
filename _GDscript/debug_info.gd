extends Node

func _ready() -> void:
	await get_tree().create_timer(1).timeout
	_update_info()

func _update_info():
	$music.text = "Music: " + str(MusicManager.player.stream)
	$fps.text = "FPS: " + str(Engine.get_frames_per_second())
	await get_tree().create_timer(1).timeout	
	_update_info()
