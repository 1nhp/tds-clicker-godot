extends Node

@onready var player = $music
var tracks

func _ready() -> void:
	# Get tracks once
	tracks = get_tracks()	
	Dlc.DLCLoadSuccesful.connect(_on_succes)
	play_music()
	
func _on_succes():
		tracks = get_tracks()	
func get_tracks():
	# Set blank tracks variable
	var tracks = []
	
	# Load files from the folder variable
	var files = ResourceLoader.list_directory("res://assets/music/")
	
	# For loop that loops the files directory and checks if file
	# ends with .ogg if so item loads then appends it to tracks
	for file in files:
		if file.ends_with(".ogg"):
			var item = ResourceLoader.load("res://assets/music/" + file)
			tracks.append(item)
			
	print(tracks)
	return tracks
	
func play_music():
	var path = tracks.pick_random()
	var stream = tracks.pick_random()
	
	player.stream = stream
	player.play()

func reset():
	player.stop()
	tracks = get_tracks()
	play_music()


func _on_music_finished() -> void:
	play_music()
