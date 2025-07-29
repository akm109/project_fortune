extends Node


var solution: Array[Array]
var reverse_solution: Array[Array]
var reduced_solution: Array[Array]
var true_solution: Array[Array]
var file: FileAccess
@export var difficulty: int = 50


func _ready() -> void:
	file = FileAccess.open("res://generated_sudoku.txt", FileAccess.WRITE)


func _process(delta: float) -> void:
	for _i in range(100):
		generate_problem()
		var content: String
		for row in range(9):
			for col in range(9):
				content += str(reduced_solution[row][col])
		file.store_line(content)
		file.flush()
		solution.clear()
		reduced_solution.clear()
	var popit: int = 0
	popit +=1

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
