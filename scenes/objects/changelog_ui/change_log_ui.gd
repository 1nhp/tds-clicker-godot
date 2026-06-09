extends Node

@export var InfoText: RichTextLabel
@export var VersionButtons: Node
@export var InfoContainer: ScrollContainer
@export var GoToTopButton: Button
@export var anim_player: AnimationPlayer
@export var changelog_root: Control

var is_button_visible := false
var current_tween: Tween
var current_article = load("res://data/changelog_ui/1.2_beta.tres")

func _ready() -> void:
	for child in VersionButtons.get_children():
		var data = child.get_meta("data")
		child.text = data["name"]
		child.clicked.connect(func(button): _on_changelog_button_pressed(button, data))
		
	GoToTopButton.modulate.a = 0
	switch_article(current_article)
	SoundManager.play_sound("ChangelogOpen")
	
func _on_changelog_button_pressed(button: Button, data) -> void:
	switch_article(data)

func switch_article(data):
	if current_tween and current_tween.is_running():
		current_tween.kill()
	
	current_tween = create_tween()
	current_tween.parallel().tween_property(InfoContainer, "modulate:a", 0, 0.1)
	current_tween.parallel().tween_property(InfoContainer, "position:x", 174.0, 0.1)
	await current_tween.finished
	InfoText.text = data["text_" + Globals.global_settings["language"]]
	InfoContainer.scroll_vertical = 0
	
	current_tween = create_tween()
	current_tween.parallel().tween_property(InfoContainer, "modulate:a", 1, 0.1)
	current_tween.parallel().tween_property(InfoContainer, "position:x", 164.0, 0.2)

func _process(delta: float) -> void:
	var should_show := InfoContainer.scroll_vertical >= 200
	
	if should_show != is_button_visible:
		is_button_visible = should_show
		
		if is_button_visible: GoToTopButton.visible = true
		
		var tween = create_tween()
		tween.tween_property(GoToTopButton, "modulate:a", 1.0 if is_button_visible else 0.0, 0.1)
		
		if !is_button_visible:
			tween.tween_callback(func():GoToTopButton.visible = false)

func _on_top_button_clicked(button: Button) -> void:
	var tween = create_tween()
	InfoContainer.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED
	tween.tween_property(InfoContainer, "scroll_vertical", 0, 0.2)
	
	GoToTopButton.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED
	await get_tree().create_timer(0.2).timeout
	InfoContainer.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_ENABLED
	GoToTopButton.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_ENABLED

	is_button_visible = false
	create_tween().tween_property(GoToTopButton, "modulate:a", 0, 0.2)

func _on_close_button_pressed() -> void:
	Globals.game.menuController.close_menu(changelog_root, anim_player, "anim", true, true, true)
	Globals.game.changelog_button.disabled = false
