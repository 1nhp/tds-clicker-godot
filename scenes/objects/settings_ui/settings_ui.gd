extends Control
@onready var graphicstab = get_tree().get_first_node_in_group("graphicstab")
@onready var audiotab = get_tree().get_first_node_in_group("audiotab")
@onready var gametab = get_tree().get_first_node_in_group("gametab")
@onready var SettingsLogic = get_tree().get_first_node_in_group("SettingsLogic")
@onready var audiovolume = get_tree().get_first_node_in_group("audiovolume")
@onready var musicvolume = get_tree().get_first_node_in_group("musicvolume")	
@onready var coin_particles = get_tree().get_first_node_in_group("coin_particles")		
@onready var language = get_tree().get_first_node_in_group("language")		

var closing: bool

func _ready() -> void:
	$Window/gamever.text = Globals.game.version
	$AnimationPlayer.play("scale")
	
	audiovolume.value = Globals.game.settings["soundvolume"]
	musicvolume.value = Globals.game.settings["musicvolume"]
	coin_particles.selected = Globals.game.settings["dropdown_selection"]["coin_particles"]
	language.selected = Globals.game.settings["dropdown_selection"]["language"]

func _on_close_button_clicked(_button: FancyButton) -> void:
	closing = true
	$AnimationPlayer.play_backwards("scale")
	get_tree().get_first_node_in_group("settings_button").disabled = false
	Globals.game._blur_screen(false)

func _switch_tab(tab):
	for t in [graphicstab,audiotab,gametab]:
		t.visible = false
	tab.visible = true

func _on_graphics_tab_button_clicked(_button: FancyButton) -> void: _switch_tab(graphicstab)
func _on_audio_tab_button_clicked(_button: FancyButton) -> void: _switch_tab(audiotab)
func _on_game_tab_button_clicked(_button: FancyButton) -> void: _switch_tab(gametab)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if closing:
		queue_free()
