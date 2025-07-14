extends GridContainer

class_name Sudoku

@onready var cell_path = SLib.globalize_path("res://Scene/World/cell.tscn")

var solution:Array[Array]
var reduced_solution:Array[Array]
var cells:Array[Control]
var highlighted_hint: int
var all_white: bool
var shown_numbers: Array[Array]

func _ready()-> void:
	cells.resize(81)
	for i in range(81):
		var cell = load(cell_path).instantiate()
		cell.assign_id(i)
		add_child(cell)
		cells[i] = cell
	solution.resize(9)
	reduced_solution.resize(9)
	for row in range(9):
		reduced_solution[row] = []
		reduced_solution[row].resize(9)
		solution[row] = []
		solution[row].resize(9)
		for col in range(9):
			solution[row][col] = 0
	solve()
	solution = randomize_sol(solution)
	for row in range(9):
		for col in range(9):
			reduced_solution[row][col] = solution[row][col]
	reduced_solution = solution
	reduct_numbers(randi_range(50,61))
	assign_numbers()
	delete_init_hints()
	shown_numbers = reduced_solution.duplicate()


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


func unhighlight_hints()-> void:
	for cell in cells:
		cell.back.set_color(Color.WHITE)
		for hint in cell.hints:
			hint.label_settings.set_font_color(Color.BLACK)
			hint.label_settings.set_font_size(16)
	all_white = true
	highlighted_hint = 0
	Global.choosen_hint = -1


func print_matrix(matrix:Array[Array])-> void:                        # pretty matrix  print
	print("\n")
	for row in matrix:
		print(row)
	print("\n")


func reduct_numbers(count)-> void:
	for i in range(count):                                              # delete count times numbers
		var row = randi()%9
		var col = randi()%9
		while reduced_solution[row][col] == 0:                          # you cant delete nothingess
			row = randi()%9
			col = randi()%9
		reduced_solution[row][col] = 0                                  # Finish him


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
		if cell.show_numb == 0:
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
		if cell.show_numb == 0:
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
	for col in range(solution.size()):
		if matrix[index[0]][col] == attempted_number and col != index[1]:
			return true
	return false


func check_repeating_number_col(attempted_number:int, index:Array[int], matrix: Array[Array])-> bool:
	# Will check for any repeating number in a row
	for row in range(solution.size()):
		if matrix[row][index[1]] == attempted_number and row != index[0]:
			return true
	return false


func check_repeating_number_in_box(attempted_number:int, index:Array[int], matrix: Array[Array])-> bool:
	# Will check for any repeating number in a box
	var box_row = int(index[0] / 3)
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
	for i in range(100):
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
