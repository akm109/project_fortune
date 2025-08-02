extends Panel

@onready var tab_container: TabContainer = $TabContainer
@onready var resolution_option_button: OptionButton = $TabContainer/VIDEO/GridContainer/ResolutionOptionButton

var resolutions: Dictionary={
	"800x600": Vector2i(800,600),
	"1280x720": Vector2i(1280,720),
	"1366x768": Vector2i(1366,768),
	"1440x900": Vector2i(1440,900),
	"1600x900": Vector2i(1600,900),
	"1680x1050": Vector2i(1680,1050),
	"1920x1080": Vector2i(1920,1080),
	"2560x1440": Vector2i(2560,1440),
	"3840x2160": Vector2i(3840,2160)
}
@onready var window: Window = get_window()

signal exit_settings


func _ready() -> void:
	var screen_size: Vector2i = DisplayServer.screen_get_size()
	window.set_max_size(screen_size)
	window.set_min_size(Vector2i(800,600))
	for i in resolutions.keys():
		resolution_option_button.add_item(i)
	
	for tab in tab_container.get_children():
		for node in tab.get_children():
			if node is Button:
				node.connect("pressed",_on_back_button_pressed)
	update_buttons()


func update_buttons()-> void:
	
	var res: String = "asd"
	for i in resolutions.keys():
		var a = window.get_size()
		if resolutions[i] == a:
			res = i
	for idx in range(resolution_option_button.item_count):
		var b = resolution_option_button.get_item_text(idx)
		if b == res:
			resolution_option_button.select(idx)
	print(res)


func _on_back_button_pressed() -> void:
	hide()
	emit_signal("exit_settings")


func center_window()-> void:
	var screen_size: Vector2i = DisplayServer.screen_get_size()
	var displayed_size: Vector2i = window.get_size_with_decorations()
	window.set_position((screen_size-displayed_size)/2)


func _on_resolution_option_button_item_selected(index: int) -> void:
	var res: String = resolution_option_button.get_item_text(index)
	window.set_size(resolutions[res])
	center_window()
	update_buttons()
	
