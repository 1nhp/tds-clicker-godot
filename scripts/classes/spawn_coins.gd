extends Node
class_name SpawnCoins

# Spawns a random number of coins between min and max at a position
func spawn(min_amount: int, max_amount: int, position: Vector2 = Vector2(30, 30)) -> void:
	var max_effects = min(min_amount, max_amount) 
	for i in range(max_effects):	
		var offset_x = randi() % 181 - 90  # random int between -90 and 90
		var offset_y = randi() % 181 - 90  # random int between -90 and 90
		var coin_position = position + Vector2(offset_x, offset_y)

		# Create the coin effect
		var coin_obj = object.create("coin_effect",Vector2(0, 0), "/root/game/FG/Objects")	
		coin_obj.position = coin_position
