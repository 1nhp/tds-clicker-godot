extends Node

var scenes := {
	"coin_effect": "res://scenes/objects/coin_effect/coin_effect.tscn",
	"debug_info": "res://scenes/objects/debug_info/debug_info.tscn",
	"ui_store": "res://scenes/objects/store_ui/store.tscn",
	"ui_settings": "res://scenes/objects/settings_ui/settings.tscn",
	"notification": "res://scenes/objects/notification/notification.tscn",
	"coin_particles": "res://scenes/objects/coin_particles/coin_particles.tscn"
}

var cache := {}

func create(scene_name: String, position: Vector2 = Vector2.ZERO, parent_path: NodePath = NodePath("")) -> Node:
	if not scenes.has(scene_name):
		push_error("Scene not registered: " + scene_name)
		return null

	if not cache.has(scene_name):
		cache[scene_name] = load(scenes[scene_name])

	var instance = cache[scene_name].instantiate()
	if not instance is CanvasLayer:
		instance.position = position
	else:
		instance.offset = position
		
	var parent_node: Node = null
	
	if parent_path != NodePath(""):
		parent_node = get_node_or_null(parent_path)
		if parent_node == null:
			return null
	else:
		parent_node = get_tree().current_scene

	parent_node.add_child(instance, true)

	return instance
