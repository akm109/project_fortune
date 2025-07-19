extends Node


func _ready() -> void:
	pass



func extract_intersects(rows, cols, base_row)-> Array:
	var buf: Array = []
	for elt in rows[base_row]:
		buf.push_back(cols.pop_at(elt))
		for intersecting_row in buf[-1]:
			for other_elt in rows[intersecting_row]:
				if other_elt != elt:
					cols[other_elt].erase(intersecting_row)
	return buf


func restore_intersect(rows,cols, base_row, buf)-> void:
	for elt in rows.reverse()[base_row]:
		cols[elt] = buf.pop_back()
		for added_row in cols[elt]:
			for col in rows[added_row]:
				cols[col].push_back[added_row]


func algorithm_x(rows,cols, cover=[]):
	if cols.is_empty():
		return cover
	else:
		var c = find_min(cols)
		for subset in cols:
			cover.push_back(subset)
			var buf_cols = extract_intersects(rows,cols,subset)
			var s = algorithm_x(rows,cols,cover)
			
			if s == []:
				return s
			restore_intersect(rows,cols,subset,buf_cols)
			cover.pop_back()
		return []


func find_min(pong: Array[Array])-> int:
	var index: int
	var prev_counter: int = 0
	for i in range(pong.size()):
		var counter: int = 0
		for j in range(pong[i].size()):
			if pong[i][j] == 0:
				counter +=1
		if counter > prev_counter:
			index = i
	return index
