extends Control


@onready var ordinary_sudoku: GridContainer = $AspectRatioContainer/OrdinarySudoku
@onready var stone_container: HBoxContainer = $Panel/StoneContainer
@onready var bag: Sprite2D = $VBoxContainer/CenterContainer2/Control/Bag


var stone_path = load(SLib.globalize_path("res://Scene/World/stone.tscn"))
var stone_count
var stones := []
var stone_recess:= []
var lying_stones:=[]

func _ready() -> void:
	var y_placement = (stone_container.get_rect().end - stone_container.get_rect().size/2).y
	for i in range(5):
		var stone = stone_path.instantiate()
		stone.assign_heritage()
		stone.dropped.connect(_on_stone_dropped)
		stone_container.add_child(stone)
		stone.position.y = y_placement
		stones.append(stone)
		stone.took_stone.connect(_on_took_stone)
	place_stones()
	


func _input(event: InputEvent) -> void:

	if event.is_action_pressed("hint_1"):
		ordinary_sudoku.highlight_hints(1)
		print("highlighted!!!!")
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
			print(ordinary_sudoku.cells[i],"       ",ordinary_sudoku.cells[i].get_rect())


func place_stones():
	stone_count = stones.size()
	stone_recess.resize(stone_count)
	lying_stones.resize(stone_count)
	for i in range(stone_count):
		stones[i].position.x = (i+1)*stone_container.get_rect().size.x/(stone_count+1)
		stone_recess[i] = stones[i].global_position
		stones[i].ID = i
		lying_stones[i] = stones[i]


func _on_stone_dropped(stone):
	if Global.hovered_cell != null:
		var cell = Global.hovered_cell
		if cell.show_numb == 0:
			cell.assign_number(stone.heritage.number)
			stone.hide()
			stone.set_global_position(bag.global_position)
			stone.in_bag = true
	else:
		pass


func get_closest_recess(stone)-> int:
	var answer: int = 0
	var min: Vector2 = (stone_recess[0] - stone.global_position).lenth_squared()
	for i in range(1,stone_recess.size()):
		var variant: Vector2
		variant = (stone_recess[i] - stone.global_position).lenth_squared()
		if variant < min:
			min = variant
			answer = i
	return answer


func _on_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		pass


func _on_button_pressed() -> void:
	pass # Replace with function body.


func relocate_stones():

	for i in range(lying_stones.size()):
		lying_stones[i].position.x = (i+1)*stone_container.get_rect().size.x/(lying_stones.size()+1)
		stone_recess[i] = lying_stones[i].global_position



func _on_took_stone(stone):
	lying_stones.erase(stone)
	relocate_stones()
	
