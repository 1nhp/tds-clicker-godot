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
	var dir = DirAccess.open(folder)

	dir.list_dir_begin()
	var file = dir.get_next()

	while file != "":
		if file.ends_with(".tres"):
			var item = load(folder + "/" + file)
			items.append(item)
		file = dir.get_next()
	dir.list_dir_end()
	
	items.sort_custom(func(a,b): 
		return a.price < b.price)

	return items
