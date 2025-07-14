extends Control





@onready var ordinary_sudoku: GridContainer = $AspectRatioContainer/OrdinarySudoku
@onready var stone_container: HBoxContainer = $Panel/StoneContainer
@onready var bag: Sprite2D = $VBoxContainer/CenterContainer2/Control/Bag


var stone_path = load(SLib.globalize_path("res://Scene/World/stone.tscn"))
var stones :Array[Stone]
var stone_recess: Array[Vector2]
var lying_stones:Array[Array]=[]


func _ready() -> void:
	lying_stones.resize(11)
	var y_placement = (stone_container.get_rect().end - stone_container.get_rect().size/2).y
	for i in range(11):
		var stone: Stone = stone_path.instantiate()
		stone.assign_heritage()
		stone.dropped.connect(_on_stone_dropped)
		stone.taken.connect(_on_taken)
		stone_container.add_child(stone)
		stone.position.y = y_placement
		stones.append(stone)
		lying_stones[i]= [stone.heritage.number,stone.heritage.type]
		stones[i].ID = i
	place_stones()
	
	for cell in ordinary_sudoku.cells:
		cell.here.connect(_on_here)


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
		print(lying_stones)


func _on_here(cell: Cell)-> void:
	var hint_to_change: int = Global.choosen_hint
	var cell_location: Array[int] = [int(cell.ID/9),cell.ID%9]
	if cell.show_numb != 0 or not ordinary_sudoku.check_loyalty(hint_to_change, cell_location , ordinary_sudoku.shown_numbers):
		return
	if hint_to_change != -1:
		cell.hints[hint_to_change-1].set_visible(not cell.hints[hint_to_change-1].is_visible())
		if cell.hints[hint_to_change-1].is_visible():
			cell.back.set_color(Color(0.7, 0.95, 1.0))
		else:
			cell.back.set_color(Color.WHITE)


func place_stones():
	if stone_recess.size() != 11:
		stone_recess.resize(11)
		for i in range(stone_recess.size()):
			stones[i].position.x = (i+0.5)*stone_container.get_rect().size.x/(stone_recess.size())
			stone_recess[i] = stones[i].global_position
	else:
		for i in range(stones.size()):
			stones[i].global_position = stone_recess[i]


func _on_stone_dropped(stone: Stone):
	if Global.hovered_cell != null:
		var cell = Global.hovered_cell
		if cell.show_numb == 0:
			cell.assign_number(stone.heritage.number, stone.heritage.type)
			ordinary_sudoku.shown_numbers[cell.ID/9][cell.ID%9] = stone.heritage.number
			ordinary_sudoku.delete_hints()
			stone.hide()
			stone.set_global_position(bag.global_position)
			stone.in_bag = true
			ordinary_sudoku.highlight_hints(stone.heritage.number)
			lying_stones.erase([stone.heritage.number,stone.heritage.type])
	else:
		ordinary_sudoku.unhighlight_hints()


func _on_taken(stone: Stone)-> void:
	await get_tree().create_timer(0.05).timeout
	ordinary_sudoku.highlight_hints(stone.heritage.number)


func _on_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		pass


func _on_button_pressed() -> void:
	Global.bag_rocks.append_array(lying_stones)
	for stone in stones:
		stone.assign_heritage()
		place_stones()
		stone.set_visible(true)
