extends Node

var scenes := {
	"coin_effect": "res://scenes/objects/coin_effect/coin_effect.tscn",
	"debug_info": "res://scenes/objects/debug_info/debug_info.tscn",
	"ui_store": "res://scenes/objects/store_ui/store.tscn",
	"error_notification": "res://scenes/objects/error_notification/error_notification.tscn",
	"coin_particles": "res://scenes/objects/coin_particles/coin_particles.tscn"
}

var cache := {}

func create(scene_name:String, position:Vector2 = Vector2.ZERO) -> Node:
	if not scenes.has(scene_name):
		push_error("Scene not registered: " + scene_name)
		return null

	if not cache.has(scene_name):
		cache[scene_name] = load(scenes[scene_name])

	var instance = cache[scene_name].instantiate()
	if not instance is CanvasLayer:
		instance.position = position
	get_tree().current_scene.add_child(instance)

	return instance
