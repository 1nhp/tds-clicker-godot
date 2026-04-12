extends Control

var message
enum types {NORMAL, WARNING, ERROR, GOOD}
var type_var = types.ERROR
var notification_sound = "Notification"

@export var text_node: Node

var text_color = Color(1,1,1)
var text_outline_color = Color(0,0,0)

var tween: Tween

func setup_text(type = types.NORMAL):
	type = type_var
	if type_var == types.ERROR:
		notification_sound = "NotificationError"
		text_color = Color(1, 0, 0)
		text_outline_color = Color(1.0, 1.0, 1.0, 1.0)
	elif type_var == types.WARNING:
		text_color = Color(1.0, 0.643, 0.0, 1.0)
		text_outline_color = Color(0.365, 0.365, 0.365, 1.0)
	elif type_var == types.GOOD:
		text_color = Color(0, 1, 0, 1.0)
		text_outline_color = Color(0.282, 0.282, 0.282, 1.0)

	SoundManager.play_sound(notification_sound)
	text_node.set("theme_override_colors/font_color", text_color)
	text_node.set("theme_override_colors/font_outline_color", text_outline_color)
	text_node.text = message
	
func _ready() -> void:
	EventBus.notification.connect(setup_text)

	text_node.scale = Vector2.ZERO
	animate_text()
	
func animate_text():
	tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(text_node, "scale", Vector2(0.8, 0.8), 0.33)
	
	await get_tree().create_timer(2).timeout
	
	tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(text_node, "modulate:a", 0, 0.4)
	tween.tween_property(text_node, "scale", Vector2(0, 0), 0.4)
	await tween.finished
	queue_free()
