extends Control


@onready var number: Label = $Number
@onready var top_color_rect: ColorRect = $TopColorRect
@onready var right_color_rect: ColorRect = $RightColorRect
@onready var bottom_color_rect: ColorRect = $BottomColorRect
@onready var left_color_rect: ColorRect = $LeftColorRect
@onready var back: ColorRect = $Back


var ID: int
var show_numb:= 0
var hints:=[]


func _ready() -> void:
	for child in get_children():
		if (child is Label) and (child.get_name() !="Number"):
			child.set_text(child.get_name())
			child.set_horizontal_alignment(1)
			hints.append(child)
	for hint in hints:
		hint.label_settings.set_font_color(Color.BLACK)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if is_mouse_in():
			Global.hovered_cell = self
		elif Global.hovered_cell == self:
			Global.hovered_cell = null


func assign_id(pop:int)->void:
	ID = pop
	await ready
	var bottom_list:= []
	for i in range(9):
		bottom_list.append(18+i)
		bottom_list.append(45+i)
		bottom_list.append(72+i)
	var top_list:=[]
	for i in range(9):
		top_list.append(i)
		top_list.append(27+i)
		top_list.append(54+i)
	if ID % 3 == 0:
		blacken(left_color_rect)
		if ID % 9 == 0:
			left_color_rect.custom_minimum_size.x = 10
	if ID % 3 == 2:
		blacken(right_color_rect)
		if ID % 9 == 8:
			right_color_rect.custom_minimum_size.x = 10
	if bottom_list.has(ID):
		blacken(bottom_color_rect)
		if ID in range(72,81):
			bottom_color_rect.custom_minimum_size.y = 10
	if top_list.has(ID):
		blacken(top_color_rect)
		if ID in range(9):
			top_color_rect.custom_minimum_size.y = 10


func assign_number(dop):
	number.set_text(str(dop))
	show_numb = dop



func delete_number():
	show_numb = 0
	number.set_text("")


func blacken(border: ColorRect):
	border.set_color(Color.BLACK)
	border.set_z_index(1)



func show_number():
	number.set_text(str(show_numb))
	number.set_visible(true)


func _on_number_placed(cell_id:int ):
	pass


func is_mouse_in() -> bool:
	var pos: Vector2 = get_global_position()
	var mouse_pos: Vector2 = get_global_mouse_position()
	if (mouse_pos.y > pos.y) and (mouse_pos.y < (pos.y + size.y)):
		if (mouse_pos.x > pos.x) and (mouse_pos.x < (pos.x + size.x)):
			return true
	return false

func _on_mouse_entered() -> void:
	if Global.hovered_cell != self:
		Global.hovered_cell = self


func _on_mouse_exited() -> void:
	if Global.hovered_cell == self:
		Global.hovered_cell = null
