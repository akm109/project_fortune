extends TextureButton


@export var enemy_id: int

func _ready() -> void:
	pass


func _on_pressed() -> void:
	for i in get_children():
		if i.is_in_group("Enemy"):
			BattleHandler.choosen_enemy = i
	
