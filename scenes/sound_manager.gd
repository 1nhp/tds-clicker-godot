extends Node2D

var sound_node = null

func play_sound(node, pitch: float = 1):
	var soundnode = get_node(node)
	soundnode.pitch_scale = pitch
	sound_node = node
	soundnode.play()
