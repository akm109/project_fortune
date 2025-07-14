extends Node


var const_rocks: Array[Array]
var bag_rocks: Array[Array]
var types:Array[String]= ["attack","deffend","magic","special"]
var hovered_cell: Cell
var choosen_hint: int = -1


func _ready() -> void:
	if const_rocks == []:
		const_rocks = make_base_rock_set()
	bag_rocks = const_rocks.duplicate(true)


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
