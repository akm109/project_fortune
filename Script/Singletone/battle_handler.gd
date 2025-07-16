extends Node


var enemy_stats: Dictionary = {
	"hp": 0,
	"shield":0
}

var player_stats: Dictionary = {
	"hp": 0,
	"shield": 0,
	"magick": 0,
	"special": 0
}


func _on_placed_stone(stone: Stone):
	var type = stone.heritage.type
	var number = stone.heritage.number
	match type:
		"attack":
			enemy_stats.hp -= number
		"deffend":
			player_stats.shield += number
		"magick":
			player_stats.magick += number
		"special":
			player_stats.special += number
