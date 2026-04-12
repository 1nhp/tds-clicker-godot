extends Node2D

func _enter_tree() -> void:
	scale = Vector2(0, 0)
func _ready() -> void:
	var node = Globals.game.coin_icon
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	var s = randf_range(1, 2)
	tween.tween_property(self, "scale", Vector2(s, s), 0.5)
	tween.tween_property(self, "position", Vector2(node.global_position.x + 20, node.global_position.y + 20), randf_range(0.5, 0.7))
	tween.tween_property(self, "scale", Vector2(0, 0), 0.5)	
	tween.finished.connect(_on_anim_finished)
	
func _on_anim_finished():
	SoundManager.play_sound("CoinCollect")
	Globals.game.update_coin_count()
	queue_free()
