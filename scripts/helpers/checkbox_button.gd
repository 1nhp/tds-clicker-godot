extends FancyButton
class_name CustomCheckbox

@export var option: String = "blur_bg"

func _button_init():
	toggled.connect(_on_toggled)
	button_pressed = _check_var_status()
	
func _on_toggled(toggled_on: bool) -> void:
	game.settings[option] = toggled_on
	print(game.settings)
		
func _check_var_status():
	var status = game.settings[option]
	return status
