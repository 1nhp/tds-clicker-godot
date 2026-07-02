extends Node

# Reference to game
var game = Globals.game

# Store data
var store_items = []
var upgrade_data = {}
var current_item
var upgrade_containers = {}

# Signals
signal FinishedLoading

var thread: Thread
var mutex: Mutex

func _ready() -> void:
	thread = Thread.new()
	mutex = Mutex.new()
	thread.start(_start_loading)

func _start_loading():
	# Folder array that will later be used for
	# store item enumeration
	var folders = [
		"res://data/store/enemies/",
		"res://data/store/droopers/",
        "res://data/store/upgrades/"
	]
	# Loop according to the folders array
	for folder in folders:
		# Set items variable and append store_items to items
		var items = _enumerate_store_items(folder)
		mutex.lock()
		store_items.append_array(items)
		mutex.unlock()
	
	# When store items enumeration finishes
	emit_signal("FinishedLoading")

func _enumerate_store_items(folder):
	# Set blank items variable
	var items = []
	
	# Load files from the folder variable
	var files = ResourceLoader.list_directory(folder)
	
	# For loop that loops the files directory and checks if file
	# ends with .tres if so item loads then appends it to items
	for file in files:
		if file.ends_with(".tres"):
			var item = ResourceLoader.load(folder + "/" + file)
			items.append(item)
	
	print(items)
	
	# Sort function
	items.sort_custom(func(a,b): 
		return a.price < b.price)
	
	return items
	thread.wait_to_finish()
