extends Node2D

var sound_node = null

func play_sound(node, min_pitch: float = 1, max_pitch = 1):
	var soundnode = get_node(node)
	var pitch = randf_range(min_pitch, max_pitch)
	soundnode.pitch_scale = pitch
	sound_node = node
	soundnode.play()
