extends Control





@onready var ordinary_sudoku: GridContainer = $AspectRatioContainer/OrdinarySudoku
@onready var stone_container: HBoxContainer = $Panel/StoneContainer
@onready var bag: Sprite2D = $VBoxContainer/CenterContainer2/Control/Bag
@onready var undo_timer: Timer = $UndoTimer
@onready var undo_cooldown_timer: Timer = $UndoCooldownTimer


var stone_path = load(SLib.globalize_path("res://Scene/World/stone.tscn"))
var stones :Array[Stone] 
var stone_recess: Array[Vector2]
var lying_stones:Array[Array]=[]
var undo_list: Array[Array] =[]
var unlimited_undo: bool = false

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
	
	if event.is_action("RMB"):
		Global.paint_mode = "none"
	
	if event.is_action_released("ui_undo"):
		unlimited_undo = false
	
	if event.is_action_pressed("ui_undo"):
		un_do()
		undo_timer.start()
	
	if event.is_action_pressed("ui_undo", true) and unlimited_undo and undo_cooldown_timer.is_stopped():
		un_do()
		undo_cooldown_timer.start()


func _on_here(cell: Cell)-> void:
	var hint_to_change: int = Global.choosen_hint                                                                                   # what hint do we want to place
	var cell_location: Array[int] = [int(cell.ID/9),cell.ID%9]                                                                      # where do we want to place it

	if hint_to_change == -1: 
		return                                                                                                                      # did we even choosen hint?
	if cell.numb != 0 or not ordinary_sudoku.check_loyalty(hint_to_change, cell_location , ordinary_sudoku.shown_numbers):          # check if there is a number in cell or is it legel to place such number here
		return

	var is_hint_visible: bool = cell.hints[hint_to_change-1].is_visible()
	if Global.paint_mode == "none":
		if is_hint_visible:
			Global.paint_mode = "erase"
		else:
			Global.paint_mode = "paint"

	if Global.paint_mode == "paint":
		cell.back.set_color(Color(0.7, 0.95, 1.0))
		cell.hints[hint_to_change-1].set_visible(true)
	else:
		cell.back.set_color(Color.WHITE)
		cell.hints[hint_to_change-1].set_visible(false)
	undo_list.append([cell.ID,hint_to_change, is_hint_visible])


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
			ordinary_sudoku.shown_numbers[cell.ID/9][cell.ID%9] = stone.heritage.number
			ordinary_sudoku.delete_hints()
			stone.hide()
			stone.set_global_position(bag.global_position)
			stone.in_bag = true
			ordinary_sudoku.highlight_hints(stone.heritage.number)
			lying_stones.erase([stone.heritage.number,stone.heritage.type])
			BattleHandler._on_placed_stone(stone)
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
	lying_stones.clear()
	lying_stones.resize(11)
	for i in range(stones.size()):
		var stone: Stone = stones[i]
		stone.assign_heritage()
		place_stones()
		lying_stones[i]=[stone.heritage.number,stone.heritage.type]
		stone.set_visible(true)


func un_do():
	pass

func _on_undo_timer_timeout() -> void:
	unlimited_undo = true
