extends TextureButton


var enemy_id: int


func _ready() -> void:
	pass


func _on_pressed() -> void:
	BattleHandler.choosen_enemy = enemy_id
