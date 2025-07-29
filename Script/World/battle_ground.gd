extends Control


@onready var player: Player = $VBoxContainer/PlayerContainer/Control/Player
@onready var battle_sudoku: AspectRatioContainer = $BattleSudoku
@onready var stone_container: ColorRect = $StoneContainer
@onready var main_enemy_panel: TextureButton = $VBoxContainer2/EnemyContainer/MainEnemyPanel
#BAR AND LABEL OF ENEMY
@onready var enemy_health_progress_bar: TextureProgressBar = $VBoxContainer2/GridContainer/EnemyHealthProgressBar
@onready var enemy_health_label: Label = $VBoxContainer2/GridContainer/EnemyHealthLabel
#BARs AND LABELS OF PALYER
@onready var health_bar: TextureProgressBar = $VBoxContainer/GridContainer/HealthBar
@onready var health_label: Label = $VBoxContainer/GridContainer/HealthLabel
@onready var mana_bar: TextureProgressBar = $VBoxContainer/GridContainer/ManaBar
@onready var mana_label: Label = $VBoxContainer/GridContainer/ManaLabel
@onready var special_label: Label = $VBoxContainer/GridContainer/SpecialLabel


signal battle_ended


func _ready() -> void:
	player.is_in_battle = true
	player.sprite_2d.play(&"idle")
	battle_sudoku.stone_container = stone_container
	BattleHandler.ui_updater = self
	BattleHandler.player = player


func update_stats()-> void:
	var enemy: Enemy = BattleHandler.choosen_enemy
	health_bar.value = player.stats.hp
	health_label.text = str(player.stats.hp)
	print(enemy.stats.hp)
	if enemy != null:
		enemy_health_label.text = str(enemy.stats.hp)
		enemy_health_progress_bar.value = enemy.stats.hp
	if player.dead:
		battle_ended.emit()
	if BattleHandler.choosen_enemy.dead:
		battle_ended.emit()
