extends Node

const ENEMY_PANEL = preload("res://Scene/Enemy/enemy_panel.tscn")

@onready var battle_ground: Control = $CanvasLayer/UI/BattleGround
@onready var player: Player = $Player


var current_level: TileMapLayer
var current_enemy: Enemy
var panels: Array

func _ready() -> void:
	battle_ground.battle_ended.connect(_on_battle_ended)
	var enemies = get_tree().get_nodes_in_group("Enemy")
	for enemy in enemies:
		enemy.start_battle.connect(_on_started_battle)

# Place connects here later
func _on_entered_level()-> void:
	pass


func _on_started_battle(enemy: Enemy)-> void:
# We should stop processing level and start process of battleground
	battle_ground.set_process_mode(Node.PROCESS_MODE_PAUSABLE)
	player.set_process_mode(Node.PROCESS_MODE_DISABLED)
#	current_level.set_process_mode(Node.PROCESS_MODE_DISABLED)
	current_enemy = enemy
	BattleHandler.choosen_enemy = enemy
	BattleHandler.enemies.append(enemy)
	var j: int =0
# We take comrades from enemy and check if they are valid
	for i in enemy.comrades.keys():
		var comrade = enemy.comrades[i]
		if comrade !=  null:
			if ResourceLoader.exists(comrade):
				j +=1
#Make panel and processing unit for every comrade
				var pop: Enemy = load(comrade).instantiate()
				var panel = ENEMY_PANEL.instantiate()
				BattleHandler.enemies.append(pop)
				battle_ground.enemy_container.add_child(panel)
				panel.add_child(pop)
				panel.enemy_id = j
# If there is more than 2 enemise we change amount of columns to two 
				if j == 2:
					battle_ground.enemy_container.set_columns(2)
# We can accomadate only four enemies: 1 from map and three comrades
				if j > 2:
					break
	BattleHandler.ui_updater.update_stats()
	battle_ground.set_visible(true)
	


func _on_battle_ended()-> void:
	for panel in panels:
		panel.queue_free()
	current_enemy.queue_free()
	current_enemy.hide()
	battle_ground.hide()
	battle_ground.set_process_mode(Node.PROCESS_MODE_DISABLED)
	player.set_process_mode(Node.PROCESS_MODE_PAUSABLE)
#	current_level.set_process_mode(Node.PROCESS_MODE_PAUSABLE)
	current_enemy = null
	BattleHandler.enemies.clear()
