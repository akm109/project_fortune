extends Node





var enemies: Array[Enemy]
var player: Player


func _on_battle_started():
	pass


func _on_enemies_turn()-> void:
	for enemy in enemies:
		enemy.make_move()


func deal_damage(damage: int,times: int, target)-> void:
	for _i in times:
		if target.stats.shield > 0:
			target.stats.shield -= damage
			if target.stats.shield < 0:
				target.stats.hp += stats.shield
				target.stats.shield = 0
		else:
			target.stats.hp -= damage


func apply_shield(amount: int, target)-> void:
	target.stats.shield += amount


func _on_placed_stone(stone: Stone):
	var type = stone.heritage.type
	var number = stone.heritage.number
	match type:
		"attack":
			deal_damage(number, 1, enemies[1])
		"deffend":
			apply_shield(number, player)
		"magick":
			player.stats.magick += number
		"special":
			player.stats.special += number
