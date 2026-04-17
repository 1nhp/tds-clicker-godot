extends FancyButton
class_name CustomCheckbox

@export var option: String = "blur_bg"
@export var is_from_globals: bool = false

func _button_init():
	button_pressed = _check_var_status()
	
func _on_toggled(toggled_on: bool) -> void:
	if not is_from_globals:
		Globals.game.settings[option] = toggled_on
		print(Globals.game.settings)
	else:
		Globals.global_settings[option] = toggled_on
		print(Globals.global_settings)
		
func _check_var_status():
	if not is_from_globals:
		var status = Globals.game.settings[option]
		return status
	else:
		var status = Globals.global_settings[option]
		return status
