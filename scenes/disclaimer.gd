extends CanvasLayer

func _ready() -> void:
	$AnimationPlayer.play("anim")
func _on_agree_clicked(_button: FancyButton) -> void:
	$AnimationPlayer.play("anim2")
func _on_agree_2_clicked(_button: FancyButton) -> void:
	if Globals.running_from_source:
		$AnimationPlayer.play("anim3")
	else:
		get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_agree_3_clicked(_button: FancyButton) -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")
