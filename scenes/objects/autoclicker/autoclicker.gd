extends Control

func _ready() -> void:
	shoot()
	
func shoot():
	while true:
		await get_tree().create_timer(5).timeout
		EventBus.click_enemy()
		var tween = create_tween()
		tween.tween_property(self, "rotation", deg_to_rad(-10), 0.1)
		SoundManager.play_sound("Gunshot", 0.9, 1.4)

		await get_tree().create_timer(0.1).timeout
		var tween2 = create_tween()
		tween2.tween_property(self, "rotation", deg_to_rad(0), 0.1)
		await get_tree().create_timer(0.2).timeout
		SoundManager.play_sound("GunReload", 1, 1.2)
