extends Node

var music_node = null
@export var max_music = 8
# Execute the play music function when the MusicManager enters
# the root scene
func _ready() -> void:
	play_music()

# Play music function
func play_music():
	# Generate random number that will be used
	# as number to play the node
	var rng = randi_range(1, max_music)
	music_node = get_node("music" + str(rng))
	music_node.play()
	print("MUSIC CONTOLLER: " + str(music_node))

# After music finishes execute play_music again
func _on_music_finished() -> void:
	play_music()

# Music reset function to prevent persisting between
# Scenes
func reset():
	music_node.stop()
	play_music()
