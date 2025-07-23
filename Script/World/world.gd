extends Node


@onready var battle_ground: Control = $CanvasLayer/UI/BattleGround
@onready var player: Player = $Player

var current_level: TileMapLayer
var current_enemy

func _ready() -> void:
	
	var enemies = get_tree().get_nodes_in_group("Enemies")
	for enemy in enemies:
		enemy.start_battle.connect(_on_started_battle)

# Place connects here later
func _on_entered_level()-> void:
	pass


func _on_started_battle(enemy: Enemy)-> void:
	battle_ground.set_process_mode(Node.PROCESS_MODE_PAUSABLE)
	player.set_process_mode(Node.PROCESS_MODE_DISABLED)
	current_level.set_process_mode(Node.PROCESS_MODE_DISABLED)
	current_enemy = enemy
	BattleHandler.enemies.append(enemy)
	battle_ground.set_visible(true)
	


func _on_battle_ended()-> void:
	current_enemy.set_process_mode(Node.PROCESS_MODE_DISABLED)
	battle_ground.set_process_mode(Node.PROCESS_MODE_DISABLED)
	player.set_process_mode(Node.PROCESS_MODE_PAUSABLE)
	current_level.set_process_mode(Node.PROCESS_MODE_PAUSABLE)
	current_enemy.hide()
	current_enemy = null
	battle_ground.set_visible(false)
	
