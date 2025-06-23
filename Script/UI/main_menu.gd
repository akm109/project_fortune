extends Control

@onready var menu: VBoxContainer = $Menu
@onready var settings_menu: Panel = $SettingsMenu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	settings_menu.connect("exit_settings",_on_settings_exit)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file(SLib.globalize_path("res://Scene/World/world.tscn"))


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_settings_button_pressed() -> void:
	menu.hide()
	settings_menu.set_visible(true)


func _on_settings_exit():
	menu.set_visible(true)
