extends Node

func _process(delta: float) -> void:
	await get_tree().create_timer(1)
	$music.text = "Music: " + str(MusicManager.music_node.stream)
	$fps.text = "FPS: " + str(Engine.get_frames_per_second())
