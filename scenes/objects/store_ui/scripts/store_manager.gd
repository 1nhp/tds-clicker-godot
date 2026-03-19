extends Node

@onready var game = get_tree().get_first_node_in_group("game")

# Store data
var store_items = []
var upgrade_data = {}
var current_item
var upgrade_containers = {}

signal FinishedLoading

func _ready() -> void:
	var folders = [
		"res://data/store/enemies/",
		"res://data/store/droopers/",
        "res://data/store/upgrades/"
	]
	for folder in folders:
		var items = _load_store_items(folder)
		store_items.append_array(items)
		await get_tree().process_frame
		
	# Or emit once at the end
	emit_signal("FinishedLoading")
	
func _load_store_items(folder):
	var items = []
	var files = ResourceLoader.list_directory(folder)

	for file in files:
		if file.ends_with(".tres"):
			var item = load(folder + "/" + file)
			items.append(item)

	items.sort_custom(func(a,b): 
		return a.price < b.price)

	return items
