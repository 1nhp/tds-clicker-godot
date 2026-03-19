extends Node2D
signal EnemyClicked

# Enemy variables
@export var coin_award = 1
@export_enum("Normal", "Abnormal", "Speedy") var type: String

var tex = []
@onready var game = get_tree().get_first_node_in_group("game")

# sin variables
var time: float = 0.0
@export var speed: float = 3.0
@export var amplitude: float = 0.3

# Scale varaibles
@export var final_scale = Vector2(0.5, 0.5)
@export var normal_scale = Vector2(0.4, 0.4)
@export var hover_scale = Vector2(0.3, 0.3)

# Tween reference to prevent creating multiple tweens
var tween: Tween
	
func _update_enemy(name1 = "Normal"):
	var name2 = load("res://data/store/enemies/" + str(name1 + ".tres"))
	if name2:
		coin_award = name2.coin_award
		$sprite.texture = name2.texture
		$sprite_hurt.texture = name2.texture
		$sprite.rotation = 0
		
func _process(delta: float) -> void:
	if game.settings["enemy_animations"]:
		# Increase time by delta then rotate sprite
		# Using the Sinus function
		time += delta
		$sprite.rotation = sin(time * speed) * amplitude
		$sprite_hurt.rotation = sin(time * speed) * amplitude
		
	
# If mouse is hovered or not scale the sprite but not the
# Hitbox to prevent overlapping issues

func _on_area_2d_mouse_entered() -> void:
	if game.settings["enemy_animations"]:
		create_tween().tween_property($sprite, "scale", final_scale, 0.15)

func _on_area_2d_mouse_exited() -> void:
	if game.settings["enemy_animations"]:
		create_tween().tween_property($sprite, "scale", normal_scale, 0.15)

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# When enemy is clicked play
		# death sound and emit clicked signal
		SoundManager.play_sound("EnemyKill1", randf_range(0.9, 1.3))
		EnemyClicked.emit()
		
		# Click animation
		var max_effects = min(coin_award, game.settings["coin_particles"])

		for i in range(max_effects):
			var offset_x = randi_range(-70, 70)
			var offset_y = randi_range(-70, 70)

			object.create(
				"coin_effect",
				Vector2(global_position.x + offset_x, global_position.y + offset_y)
			)
			
		if game.settings["enemy_animations"]:
			$AnimationPlayer.stop()
			$AnimationPlayer.play("hurt")
			create_tween().tween_property($sprite, "scale", Vector2(0.4, 0.4), 0.05)
			await get_tree().create_timer(0.1).timeout
			create_tween().tween_property($sprite, "scale", final_scale, 0.05)
