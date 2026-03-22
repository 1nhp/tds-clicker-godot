extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("anim")


func _on_agree_clicked(_button: FancyButton) -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")
