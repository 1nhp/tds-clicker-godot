extends CanvasLayer

@export var error_message = "You do not have enough coins to buy this item!"

func _ready() -> void:
	$header.scale = Vector2.ZERO
	_update()
	$header.modulate.a = 0
	$header.position.y = $header.position.y - 50  # or use a tween if you want smooth movement

	# Pop-in animation
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($header, "scale", Vector2(1.1, 1.1), 0.2)
	tween.tween_property($header, "modulate:a", 1, 0.2)
	await tween.finished
	
	# Bounce to final scale
	var tween2 = create_tween()
	tween2.tween_property($header, "scale", Vector2(1, 1), 0.1)
	await tween2.finished
	
	# Wait before fading out
	await get_tree().create_timer(2).timeout
	
	var tween3 = create_tween()
	tween3.tween_property($header, "modulate:a", 0, 1)
	await tween3.finished
	
	queue_free()

func _update():
	$header.text = error_message
