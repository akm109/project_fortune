extends GridContainer


@onready var pattern:= "ordinary"
@onready var block_path = SLib.globalize_path("res://Scene/World/block.tscn")
var solution:= []


func _ready()-> void:
	match pattern:
		"ordinary":
			set_columns(9)
			for i in range(81):
				var block = load(block_path).instantiate()
				block.ID = i
				add_child(block)
			for i in range(9):
				for j in range(9):
					solution.append_array([((i*3 + i/3 + j) % (9) + 1)])
			solution = randomize_solution(solution)
			for block in get_children():
				block.corr_numb = solution[block.ID]


func randomize_solution(array_solution: Array):
	var matrix_solution =[]
	matrix_solution.resize(9)
	for i in range(9):
		var intermidiate_array =[]
		for j in range(9):
			intermidiate_array.append_array([array_solution[i*9+j]])
		matrix_solution[i]= intermidiate_array
	for i in range(100):
		var k = randi() % 3
		match k:
			0:
				matrix_solution = change_cols(matrix_solution)
			1:
				matrix_solution = change_rows(matrix_solution)
			2:
				matrix_solution = transponse(matrix_solution)
	array_solution.resize(0)
	for i in matrix_solution.size():
		array_solution.append_array(matrix_solution[i])
	return array_solution


func print_matrix_pretty(matrix:Array)-> void:
	for i in range(matrix.size()):
		print(matrix[i])
	print("")


func transponse(matrix: Array)->Array:
	var rows = matrix.size()
	var cols = matrix[0].size()
	var new_matrix:= []
	new_matrix.resize(cols)
	for i in range(cols):
		new_matrix[i] = []
	for i in range(rows):
		for j in range(cols):
			new_matrix[j].append(matrix[i][j])
	return new_matrix


func change_rows(matrix:Array)->Array:
	var new_matrix: Array
	var row_1 = randi() % matrix.size()
	var row_2 = randi() % matrix.size()
	while row_1 == row_2:
		row_2 = randi() % matrix.size()
	new_matrix.resize(matrix.size())
	new_matrix[row_1] = matrix[row_2]
	new_matrix[row_2] = matrix[row_1]
	for i in range(matrix.size()):
		if (i != row_1) and (i != row_2):
			new_matrix[i] = matrix[i]
	return new_matrix


func change_cols(matrix:Array)->Array:
	matrix = transponse(matrix)
	matrix = change_rows(matrix)
	matrix =  transponse(matrix)
	return matrix
