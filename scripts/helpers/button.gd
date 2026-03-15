extends Button
class_name FancyButton

signal clicked

enum AnimationType {
	SCALE,
	POSITION
}
@export var one_click: bool = false
@export var click_animation = AnimationType.SCALE
@export var hover_animation = AnimationType.SCALE
@export var hover_scale = Vector2(1.05,1.05)

var original_position: Vector2

func _ready() -> void:
	original_position = position
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pressed.connect(_on_button_clicked)
	button_down.connect(_on_button_down)
	
func _on_mouse_entered():
	if not disabled:
		SoundManager.play_sound("ButtonHover")
		_play_anim(3)


func _on_mouse_exited():
	if not disabled:
		_play_anim(2)

func _on_button_clicked():
	clicked.emit(self)
	SoundManager.play_sound("ButtonDecide")
	_play_anim(1)
	grab_focus()
	if one_click:
		disabled = true

func _play_anim(anim):
	if anim == 1:
		match click_animation:
			AnimationType.SCALE:
				create_tween().tween_property(self, "scale", Vector2(0.9,0.9), 0.1)
				await get_tree().create_timer(0.1).timeout
				create_tween().tween_property(self, "scale", Vector2.ONE, 0.1)
	if anim == 2:
		match hover_animation:
			AnimationType.SCALE:
				create_tween().tween_property(self, "scale", Vector2.ONE, 0.1)

			AnimationType.POSITION:
				create_tween().tween_property(self, "position", original_position, 0.1)
	if anim == 3:
		match hover_animation:
			AnimationType.SCALE:
				create_tween().tween_property(self, "scale", hover_scale, 0.1)

			AnimationType.POSITION:
				create_tween().tween_property(self, "position", original_position + Vector2(0, -3), 0.1)
	if anim == 4:
		match hover_animation:
			AnimationType.SCALE:
				create_tween().tween_property(self, "scale", Vector2(0.9,0.9), 0.1)

		
func _on_button_down():
	_play_anim(2)
