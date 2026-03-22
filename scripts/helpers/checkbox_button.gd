extends FancyButton
class_name CustomCheckbox

@export var option: String = "blur_bg"

func _button_init():
	button_pressed = _check_var_status()
	
func _on_toggled(toggled_on: bool) -> void:
	Globals.game.settings[option] = toggled_on
	print(Globals.game.settings)
		
func _check_var_status():
	var status = Globals.game.settings[option]
	return status
