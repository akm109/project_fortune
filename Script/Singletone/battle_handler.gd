extends Node


var enemies: Array[Enemy]
var player: Player
var choosen_enemy
var ui_updater


func _on_battle_started():
	pass

func _process(delta: float) -> void:
	pass

func _on_enemies_turn()-> void:
	for enemy in enemies:
		enemy.make_move()
		#await enemy.end_of_turn


func deal_damage(damage: int,times: int, target)-> void:
# DEALING DAMAGE
	for _i in times:
		if target.stats.shield > 0:
			target.stats.shield -= damage
			if target.stats.shield < 0:
				target.stats.hp += target.stats.shield
				target.stats.shield = 0
		else:
			target.stats.hp -= damage
# IF TARGET HAS NEGATIVE OR ZERO HEALTH, THEN TARGET IS DEAD
	if target.stats.hp <= 0:
		target.dead = true
# UPDATE UI SO USER CAN SEE IMPACT OF MOVES!!!
	ui_updater.update_stats()


func apply_shield(amount: int, target)-> void:
	target.stats.shield += amount


func _on_placed_stone(stone: Stone):
	var type = stone.heritage.type
	var number = stone.heritage.number
	match type:
		"attack":
			pass
			deal_damage(number, 1, choosen_enemy)
			print(number,choosen_enemy,"asdasdasd")
		"deffend":
			pass
			#apply_shield(number, player)
		"magick":
			player.stats.magick += number
		"special":
			player.stats.special += number
