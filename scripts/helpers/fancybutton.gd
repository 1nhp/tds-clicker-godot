extends Button
class_name FancyButton

signal clicked

enum AnimationType {
	SCALE,
	POSITION
}

enum Anim{
	HOVER_IN,
	HOVER_OUT,
	CLICK
}

@export var one_click: bool = false
@export var click_animation = AnimationType.SCALE
@export var hover_animation = AnimationType.SCALE
@export var hover_scale = Vector2(1.05,1.05)
@export var node: Node = self

var original_position: Vector2

func _ready() -> void:
	original_position = position
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pressed.connect(_on_button_clicked)
	button_down.connect(_on_button_down)
	_button_init()

func _button_init():
	pass
	
func _on_mouse_entered():
	if not disabled:
		SoundManager.play_sound("ButtonHover")
		_play_anim(Anim.HOVER_IN)

func _on_mouse_exited():
	_play_anim(Anim.HOVER_OUT)

func _on_button_clicked():
	clicked.emit(self)
	SoundManager.play_sound("ButtonDecide")
	_play_anim(Anim.HOVER_IN)
	grab_focus()
	
	if one_click:
		disabled = true

var tween: Tween

func _play_anim(anim_type):
	if Globals.game and Globals.game.settings["ui_animations"]:
		if tween: tween.kill()
		tween = create_tween()
		tween.set_trans(Tween.TRANS_BACK)
	
		if anim_type == Anim.HOVER_IN:
			match hover_animation:
				AnimationType.SCALE:
					tween.set_ease(Tween.EASE_OUT)
					tween.tween_property(node, "scale", hover_scale * 1.02, 0.1)
					tween.tween_property(node, "scale", hover_scale, 0.1)
				
				AnimationType.POSITION:
					tween.tween_property(node, "position", original_position + Vector2(0, -6), 0.2)

		elif anim_type == Anim.HOVER_OUT:
			match hover_animation:
				AnimationType.SCALE:
					tween.tween_property(node, "scale", Vector2.ONE, 0.1)

				AnimationType.POSITION:
					tween.tween_property(node, "position", original_position, 0.1)

		elif anim_type == Anim.CLICK:
			match click_animation:
				AnimationType.SCALE:
					tween.tween_property(node, "scale", Vector2(0.95, 0.95), 0.05)
				AnimationType.POSITION:
					tween.tween_property(node, "position", original_position + Vector2(0, -3), 0.05)

func _on_button_down():
	_play_anim(Anim.CLICK)
