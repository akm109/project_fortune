extends Control


@onready var label: Label = $Label


var ID: int
var corr_numb: int
var previous_corr_numb: int
func _ready() -> void:
	for child in get_children():
		if child is Label:
			child.set_text(child.get_name())
			child.set_horizontal_alignment(1)
			#child.hide()


func _process(_delta:float)->void:
	if corr_numb!= previous_corr_numb:
		label.set_text(str(corr_numb))
		label.set_visible(true)
		previous_corr_numb = corr_numb
