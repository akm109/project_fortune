extends GridContainer

class_name Sudoku

@onready var cell_path = SLib.globalize_path("res://Scene/World/cell.tscn")

@onready var undo_timer: Timer = $UndoTimer
@onready var undo_cooldown_timer: Timer = $UndoCooldownTimer
#@onready var timer: Timer = $Timer

@export var difficulty: int = 50
#Various types of solution for various purposes
var true_solution:Array[Array]          # for perfect counter
var solution:Array[Array]               # straight brute-force solution for finding correct problem
var reverse_solution:Array[Array]       # gae solution brute-force for finding correct problem
var reduced_solution:Array[Array]       # auxilary solution wwith holes
var shown_numbers: Array[Array]         # what numbers do we show in UI
#Cell related variables
var cells:Array[Control]                # Array of cells wich contains hints and shown number
var highlighted_hint: int               # What hint do we higlight righht now?
var all_white: bool                     # Is there highlited cells?
#Un_do related variables
var undo_list: Array[Array] =[]         # List of actions that we can un_do
var unlimited_undo: bool = false        # Should we start fast un_do?


func _ready()-> void:
	cells.resize(81)
	for i in range(81):
		var cell = load(cell_path).instantiate()
		cell.assign_id(i)
		cell.here.connect(_on_here)
		add_child(cell)
		cells[i] = cell
	if difficulty > 49:
		get_prepared_problem()
	else:
		generate_problem()
	reduced_solution = randomize_sol(reduced_solution)
	assign_numbers()
	delete_init_hints()
	shown_numbers = reduced_solution.duplicate(true)


func _process(_delta: float) -> void:
	
	if Input.is_action_pressed("ui_undo") and unlimited_undo and undo_cooldown_timer.is_stopped():
		un_do()
		undo_cooldown_timer.start()


func _input(event: InputEvent) -> void:

	if event.is_action_pressed("hint_1"):
		highlight_hints(1)
	if event.is_action_pressed("hint_2"):
		highlight_hints(2)
	if event.is_action_pressed("hint_3"):
		highlight_hints(3)
	if event.is_action_pressed("hint_4"):
		highlight_hints(4)
	if event.is_action_pressed("hint_5"):
		highlight_hints(5)
	if event.is_action_pressed("hint_6"):
		highlight_hints(6)
	if event.is_action_pressed("hint_7"):
		highlight_hints(7)
	if event.is_action_pressed("hint_8"):
		highlight_hints(8)
	if event.is_action_pressed("hint_9"):
		highlight_hints(9)
	
	if event.is_action_released("RMB"):
		Global.paint_mode = "none"
	
	if event.is_action_released("ui_undo"):
		undo_timer.stop()
		await undo_timer.timeout
		unlimited_undo = false
	
	if event.is_action_pressed("ui_undo") and not unlimited_undo:
		un_do()
		undo_timer.start()



func _on_here(cell: Cell)-> void:
	var hint_to_change: int = Global.choosen_hint                                                                                   # what hint do we want to place
	@warning_ignore("integer_division")
	var cell_location: Array[int] = [int(cell.ID/9),cell.ID%9]                                                                      # where do we want to place it

	if hint_to_change == -1: 
		return                                                                                                                      # did we even choosen hint?
	if cell.numb != 0 or not check_loyalty(hint_to_change, cell_location , shown_numbers):          # check if there is a number in cell or is it legel to place such number here
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


#undo hint erasing/painting
func un_do():
	if not undo_list.is_empty():
		var to_undo: Array = undo_list.pop_back()
		var cell : Cell = cells[to_undo[0]]
		var hint_numb: int = to_undo[1]
		var to_hide: bool  = to_undo[2]
		var hint: Label = cell.hints[hint_numb-1]
		hint.set_visible(to_hide)
		if Global.choosen_hint == hint_numb:
			hint.label_settings.set_font_color(Color.RED)
			hint.label_settings.set_font_size(24)
			cell.back.set_color(Color(0.7, 0.95, 1.0))
		else:
			hint.label_settings.set_font_color(Color.BLACK)
			hint.label_settings.set_font_size(16)
		if not to_hide:
			if Global.choosen_hint == hint_numb:
				cell.back.set_color(Color.WHITE)
		print("")


func _on_undo_timer_timeout() -> void:
	unlimited_undo = true


func highlight_hints(hint_ID:int):
	if  highlighted_hint == hint_ID and (not all_white):              #if we already highlited this number we should unhighlight it!!!
		for cell in cells:
			cell.back.set_color(Color.WHITE)
			for hint in cell.hints:
				hint.label_settings.set_font_color(Color.BLACK)
				hint.label_settings.set_font_size(16)
		all_white = true
		Global.choosen_hint = -1
		return
	for cell in cells:
		cell.back.set_color(Color.WHITE)                              # set everything default
		for hint in cell.hints:
			if hint.is_visible():
				hint.label_settings.set_font_color(Color.BLACK)
				hint.label_settings.set_font_size(16)
				if (hint.text == str(hint_ID)):                       #if it is possible to place here given number => highlight possibility!!
					hint.label_settings.set_font_color(Color.RED)
					hint.label_settings.set_font_size(24)
					cell.back.set_color(Color(0.7, 0.95, 1.0))
	Global.choosen_hint = hint_ID
	all_white = false                                                 # not all squares white
	highlighted_hint = hint_ID                                        #remember what we highlighted later to unhighlight later if needed


func unhighlight_hints()-> void:                                      #Just make it as it was from begining
	for cell in cells:
		cell.back.set_color(Color.WHITE)
		for hint in cell.hints:
			hint.label_settings.set_font_color(Color.BLACK)
			hint.label_settings.set_font_size(16)
	all_white = true
	highlighted_hint = 0
	Global.choosen_hint = -1


func get_prepared_problem()-> void:
	var problems: Array[Array]
	var i : int = 0
	var file:FileAccess
	if difficulty != 50:
		file = FileAccess.open("res://sudoku.txt", FileAccess.READ)
		problems.resize(50)
	else:
		file = FileAccess.open("res://generated_sudoku.txt", FileAccess.READ)
		problems.resize(117)
	while file.get_length() > file.get_position():
		problems[i].resize(81)
		var line: String = file.get_line()
		for j in range(line.length()):
			problems[i][j] = (int(line[j]))
		i += 1
	
	var problem: Array = problems[4]
	var sol: Array[Array]
	sol.resize(9)
	for k in range(9):
		sol[k].resize(9)
		for j in range(9):
			sol[k][j] = (problem[k*9+j])
	sol = replace_numbers(sol)
	reduced_solution = sol 


func generate_problem()-> void:
	solution.resize(9)
	reduced_solution.resize(9)
	for row in range(9):
		reduced_solution[row].resize(9)
		solution[row].resize(9)
		for col in range(9):
			solution[row][col] = 0
	rand_solve()
	reduced_solution = solution.duplicate(true)
	true_solution = solution.duplicate(true)
	while solution != reverse_solution:
		reduct_numbers()
		if solution != reverse_solution:
			reduced_solution = true_solution.duplicate(true)
		else:
			break


func replace_numbers(sol: Array[Array]):
	var answer: Array[Array]
	var numbers: Array[Array]
	answer.resize(9)
	numbers.resize(9)
	for number in range(9):
		numbers[number] = []
	for row in range(9):
		answer[row] = []
		answer[row].resize(9)
		for col in range(9):
			answer[row][col] = 0
			if sol[row][col] != 0:
				numbers[sol[row][col]-1].append(row*9+col)
	numbers.shuffle()
	numbers.shuffle()
	for i in range(numbers.size()):
		for j in range(numbers[i].size()):
			answer[int(numbers[i][j]/9)][numbers[i][j]%9] = i + 1
	return answer


func reduct_numbers():
	for i in range(difficulty):
		var row:int = randi()%9
		var col:int = randi()%9
		while reduced_solution[row][col] == 0:                          # you cant delete nothingess
			row = randi()%9
			col = randi()%9
		reduced_solution[row][col] = 0                                  # Finish him
	solution = reduced_solution.duplicate(true)
	reverse_solution = reduced_solution.duplicate(true)
	solve()
	reverse_solve()


func assign_numbers()-> void:                                            # Show them what you got!
	for row in range(9):
		for col in range(9):
			var cell = cells[row*9+col]
			if reduced_solution[row][col] != 0:
				cell.assign_number(reduced_solution[row][col],"none")


func delete_hints()-> void:
	for cell in cells:
		var row = int(cell.ID/9)
		var col = cell.ID % 9
		if cell.numb == 0:                                                
			for possible_values in range(1,10):
				if !check_loyalty(possible_values,[row,col], shown_numbers):
					cell.hints[possible_values-1].hide()
		else:
			for hint in cell.hints:
				hint.hide()


func delete_init_hints()-> void:
	for cell in cells:
		var row = int(cell.ID/9)
		var col = cell.ID % 9
		if cell.numb == 0:
			for possible_values in range(1,10):
				if !check_loyalty(possible_values,[row,col], reduced_solution):
					cell.hints[possible_values-1].hide()
		else:
			for hint in cell.hints:
				hint.hide()


func solve() -> bool:
	var row
	var col
	var find = find_empty(solution)
	if find == [null]:
		return true
	else:
		row = find[0]
		col = find[1]
	for possible_values in range(1,10):
		if check_loyalty(possible_values, [row, col], solution):
			solution[row][col] = possible_values
			if solve():
				return true
			solution[row][col] = 0
	return false


func reverse_solve()->bool:
	var row
	var col
	var find = find_empty(reverse_solution)
	if find == [null]:
		return true
	else:
		row = find[0]
		col = find[1]
	for possible_values in range(9,0,-1):
		if check_loyalty(possible_values, [row, col], reverse_solution):
			reverse_solution[row][col] = possible_values
			if reverse_solve():
				return true
			reverse_solution[row][col] = 0
	return false


func rand_solve():
	var row
	var col
	var find = find_empty(solution)
	if find == [null]:
		return true
	else:
		row = find[0]
		col = find[1]
	var pos_vals = range(1,10)
	pos_vals.shuffle()
	for possible_values in pos_vals:
		if check_loyalty(possible_values, [row, col], solution):
			solution[row][col] = possible_values
			if rand_solve():
				return true
			solution[row][col] = 0
	return false


func check_loyalty(attempted_number:int, index:Array[int], matrix: Array[Array])-> bool:
	if not check_repeating_number_row(attempted_number, index, matrix):
		if not check_repeating_number_col(attempted_number, index, matrix):
			if not check_repeating_number_in_box(attempted_number, index, matrix):
				return true
	return false


func find_empty(matrix)->Array:
	for row in range(matrix.size()):
		for col in range(matrix.size()):
			if matrix[row][col] == 0:
				return [row, col]
	return [null]


func check_repeating_number_row(attempted_number:int, index:Array[int], matrix: Array[Array])-> bool:
	# Will check for any of the same number in a column
	for col in range(9):
		if matrix[index[0]][col] == attempted_number and col != index[1]:
			return true
	return false


func check_repeating_number_col(attempted_number:int, index:Array[int], matrix: Array[Array])-> bool:
	# Will check for any repeating number in a row
	for row in range(9):
		if matrix[row][index[1]] == attempted_number and row != index[0]:
			return true
	return false


func check_repeating_number_in_box(attempted_number:int, index:Array[int], matrix: Array[Array])-> bool:
	# Will check for any repeating number in a box
	@warning_ignore("integer_division")
	var box_row = int(index[0] / 3)
	@warning_ignore("integer_division")
	var box_col = int(index[1] / 3)
	for row in range(box_row * 3, box_row * 3 + 3):
		for col in range(box_col * 3, box_col * 3 + 3):
			if ([row, col]) != (index) and matrix[row][col] == attempted_number:
				return true
	return false


func validation_check()-> bool:
	# If it detects any tiles that aren't valid in the sudoku then it will return false
	# no point in searching the rest of the array as once one position is invalid
	# the whole sudoku will be invalid
	for row in range(solution.size()):
		for col in range(solution.size()):
			if solution[row][col] != 0:
				if not check_loyalty(solution[row][col], [row, col], solution):
					return false
	return true


func randomize_sol(matrix: Array[Array])-> Array[Array]:
	var answer: Array[Array] = matrix.duplicate(true)
	for i in range(1000):
		var k: int
		k = randi()%5
		match k:
			0:
				answer = change_big_cols(answer)
			1:
				answer = change_big_rows(answer)
			2:
				answer = transpose(answer)
			3:
				answer = change_cols(answer)
			4:
				answer =  change_rows(answer)
	return answer


func change_rows(matrix:Array[Array])-> Array[Array]:
	var buf1:=[]
	var buf2:=[]
	var answer: Array[Array]= matrix.duplicate(true)
	var row_1: int
	var row_2: int
	var row_area:= randi()%3
	row_1 = randi()%3
	row_2 = randi()%3
	while row_1 == row_2:
		row_1 = randi()%3
		row_2 = randi()%3
	buf1 = matrix[row_1+row_area*3]
	buf2 = matrix[row_2+row_area*3]
	answer[row_1+row_area*3] = buf2
	answer[row_2+row_area*3] = buf1
	return answer


func change_big_rows(matrix:Array[Array])-> Array[Array]:
	var buf1:=[]
	var buf2:=[]
	var answer: Array[Array] = matrix.duplicate(true)
	buf1.resize(3)
	buf2.resize(3)
	var big_row_1: int
	var big_row_2: int
	big_row_1 = randi()%3
	big_row_2 = randi()%3
	while big_row_1 == big_row_2:
		big_row_1 = randi()%3
		big_row_2 = randi()%3
	for i in range(3):
		buf1[i] = []
		buf2[i] = []
	for i in range(3):
		buf1[i].append_array(matrix[i+big_row_1*3])
		buf2[i].append_array(matrix[i+big_row_2*3])
	for i in range(3):
		answer[i+big_row_1*3] = buf2[i]
		answer[i+big_row_2*3] = buf1[i]
	return answer


func change_cols(matrix:Array[Array])-> Array[Array]:
	var answer: Array[Array]  = matrix.duplicate(true)
	answer = transpose(answer)
	answer = change_rows(answer)
	answer = transpose(answer)
	return answer


func change_big_cols(matrix:Array[Array])-> Array[Array]:
	var answer: Array[Array] = matrix.duplicate(true)
	answer = transpose(answer)
	answer = change_big_rows(answer)
	answer = transpose(answer)
	return answer



func transpose(matrix:Array[Array])-> Array[Array]:
	var buff: Array[Array]
	var answer: Array[Array]
	answer.resize(9)
	buff= matrix.duplicate(true)
	for row in range(matrix.size()):
		answer[row]=[]
		answer[row].resize(9)
		for col in range(matrix.size()):
			answer[row][col]=buff[col][row]
	return answer


func print_matrix(matrix:Array[Array])-> void:                        # pretty matrix  print
	print("\n")
	for row in matrix:
		print(row)
	print("\n")
