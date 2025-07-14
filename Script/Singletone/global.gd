extends Node


var const_rocks: Array[Array]
var bag_rocks: Array[Array]
var types:= ["attack","deffend","magic","special"]
var hovered_cell
var perv_cell


func _ready() -> void:
	if const_rocks == []:
		const_rocks = make_base_rock_set()
	bag_rocks = const_rocks.duplicate(true)


func _process(delta: float) -> void:
	if hovered_cell != null and hovered_cell != perv_cell:
		print(hovered_cell, "ABOBA")
		print(hovered_cell.get_global_position(),"   POPINA  ", hovered_cell.get_global_mouse_position())
		perv_cell = hovered_cell


func make_base_rock_set() -> Array[Array]:
	var base_rocks: Array[Array]
	base_rocks.resize(81)
	for i in range(9):
		for j in range(3):
			base_rocks[i*9+j] = [i+1,"deffend"]
		for j in range(3):
			base_rocks[i*9+j+3] = [i+1,"attack"]
		for j in range(2):
			base_rocks[i*9+j+6] = [i+1,"magick"]
		base_rocks[i*9+8] = [i+1,"special"]
	return base_rocks
