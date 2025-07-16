extends Node


var main_menu_scene: PackedScene = load(SLib.globalize_path("res://Scene/UI/main_menu.tscn"))
var world_scene: PackedScene =  preload("res://Scene/World/world.tscn")
var main_menu: Control


func _ready() -> void:
	main_menu = main_menu_scene.instantiate()
	add_child(main_menu)
	main_menu.play.connect(_on_play)


func _on_play()-> void:
	add_child(world_scene.instantiate())
	main_menu.queue_free()
