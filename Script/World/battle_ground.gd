extends Control





@onready var ordinary_sudoku: GridContainer = $AspectRatioContainer/OrdinarySudoku
@onready var stone_container: HBoxContainer = $Panel/StoneContainer
@onready var bag: Sprite2D = $VBoxContainer/CenterContainer2/Control/Bag


var stone_path = load(SLib.globalize_path("res://Scene/World/stone.tscn"))
var stones := []
var stone_recess:= []
var lying_stones:=[]


func _ready() -> void:
	var y_placement = (stone_container.get_rect().end - stone_container.get_rect().size/2).y
	for i in range(11):
		var stone = stone_path.instantiate()
		stone.assign_heritage()
		stone.dropped.connect(_on_stone_dropped)
		stone.taken.connect(_on_taken)
		stone_container.add_child(stone)
		stone.position.y = y_placement
		stones.append(stone)
	place_stones()


func _input(event: InputEvent) -> void:

	if event.is_action_pressed("hint_1"):
		ordinary_sudoku.highlight_hints(1)
	if event.is_action_pressed("hint_2"):
		ordinary_sudoku.highlight_hints(2)
	if event.is_action_pressed("hint_3"):
		ordinary_sudoku.highlight_hints(3)
	if event.is_action_pressed("hint_4"):
		ordinary_sudoku.highlight_hints(4)
	if event.is_action_pressed("hint_5"):
		ordinary_sudoku.highlight_hints(5)
	if event.is_action_pressed("hint_6"):
		ordinary_sudoku.highlight_hints(6)
	if event.is_action_pressed("hint_7"):
		ordinary_sudoku.highlight_hints(7)
	if event.is_action_pressed("hint_8"):
		ordinary_sudoku.highlight_hints(8)
	if event.is_action_pressed("hint_9"):
		ordinary_sudoku.highlight_hints(9)
		for i in range(81):
			print(ordinary_sudoku.cells[i],"       ",ordinary_sudoku.cells[i].get_global_position())


func place_stones():
	stone_recess.resize(11)
	for i in range(stone_recess.size()):
		stones[i].position.x = (i+0.5)*stone_container.get_rect().size.x/(stone_recess.size())
		stone_recess[i] = stones[i].global_position
		stones[i].ID = i


func _on_stone_dropped(stone):
	if Global.hovered_cell != null:
		var cell = Global.hovered_cell
		if cell.show_numb == 0:
			cell.assign_number(stone.heritage.number)
			ordinary_sudoku.shown_numbers[cell.ID/9][cell.ID%9] = stone.heritage.number
			ordinary_sudoku.delete_hints()
			stone.hide()
			stone.set_global_position(bag.global_position)
			stone.in_bag = true
			ordinary_sudoku.highlight_hints(stone.heritage.number)
	else:
		ordinary_sudoku.unhighlight_hints()


func _on_taken(stone)-> void:
	await get_tree().create_timer(0.05).timeout
	ordinary_sudoku.highlight_hints(stone.heritage.number)


func _on_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		pass


func _on_button_pressed() -> void:
	pass # Replace with function body.
