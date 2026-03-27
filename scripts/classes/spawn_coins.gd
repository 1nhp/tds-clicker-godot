extends Node
class_name SpawnCoins

func spawn(min, max) -> void:
		var max_effects = min(min, max)

		for i in range(max_effects):
			var offset_x = randi_range(-90, 90)
			var offset_y = randi_range(-90, 90)

			object.create("coin_effect",Vector2(30 + offset_x, 30 + offset_y), "/root/game/FG/Objects")	
