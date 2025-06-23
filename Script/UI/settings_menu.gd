extends Panel

@onready var tab_container: TabContainer = $TabContainer


signal exit_settings


func _ready() -> void:
	for tab in tab_container.get_children():
		for node in tab.get_children():
			if node is Button:
				node.connect("pressed",_on_back_button_pressed)


func _on_back_button_pressed() -> void:
	hide()
	emit_signal("exit_settings")
