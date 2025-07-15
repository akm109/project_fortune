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
		var cell: Cell = Global.hovered_cell
		if cell.numb == 0:
			cell.assign_number(stone.heritage.number, stone.heritage.type)
			@warning_ignore("integer_division")
			ordinary_sudoku.shown_numbers[cell.ID/9][cell.ID%9] = stone.heritage.number
			ordinary_sudoku.delete_hints()
			stone.hide()
			stone.set_global_position(bag.global_position)
			stone.in_bag = true
			lying_stones.erase([stone.heritage.number,stone.heritage.type])
			BattleHandler._on_placed_stone(stone)
	else:
		ordinary_sudoku.unhighlight_hints()


func _on_taken(stone: Stone)-> void:
	await get_tree().create_timer(0.05).timeout
	if Global.choosen_hint != stone.heritage.number:
		ordinary_sudoku.highlight_hints(stone.heritage.number)


func _on_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		pass

# A button to thro stones back in bag and take new ones
func _on_button_pressed() -> void:
	Global.bag_rocks.append_array(lying_stones)
	lying_stones.clear()
	lying_stones.resize(11)
	for i in range(stones.size()):
		var stone: Stone = stones[i]
		stone.assign_heritage()
		place_stones()
		lying_stones[i]=[stone.heritage.number,stone.heritage.type]
		stone.set_visible(true)
