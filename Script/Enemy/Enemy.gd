extends Area2D

class_name Enemy

@export_group("Custom")
@export_subgroup("Battle_values")
@export var stats: Dictionary={
	"name": "",
	"hp": 10,
	"attack": 1,
	"shield": 1,
	"effects": []
}

@export var move_set: Dictionary = {
	"attack_st": {
		"type":"attack",
		"amount": 10,
		"number_of_attacks":1,
		"weight": 1.0
	},
	"defend_st": {
		"type":"defend",
		"amount": 10,
		"weight": 1.0
	},
	"special_st":{
		"type":"defend",
		"amount": 10,
		"weight": 0.0,
		"special": "",
	},
	"sequnce_move_st": {
		"sequnce_number": 0,
		"sequnce_name": "",
		"type":"attack",
		"amount": 10,
		"number_of_attacks":1,
		"weight": 0.0
	},
}

@export var comrades: Dictionary = {
	"comrade_path_1": null,                                   #Insert path to comrade so in battle he won't be alone
	"comrade_path_2": null,                                    #(up to 3 comrades!!)
	"comrade_path_3": null,
}

@export_subgroup("World_values")
@export var agro_range: float = 500.0
@export var guard_point: Marker2D
@export var guard_range: float
@export var guard_speed: float = 100.0
@export var chase_speed: float = 250.0

var previous_move: Dictionary
var current_move: Dictionary
var dead: bool

signal start_battle(enemy: Enemy)
signal end_of_turn

func _init()->void:
	pass


func _process(delta: float) -> void:
	pass


func make_move()-> void:
	pick_move()
# If move applies buff/debuff, whe should apply it
	if current_move.has("special"):
		match current_move.special:
			_:
				pass
# According on type of move wwe make certqain actions
	match current_move.type:
		"attack":
			BattleHandler.deal_damage(current_move.amount, current_move.number_of_attacks, BattleHandler.player)
		"defend":
			BattleHandler.apply_shield(current_move.amount, self)
	print("ethjyewffwejty")
	end_of_turn.emit()


func pick_move() -> void:
# If preious move belongs to sequence it has sequence_name we should choose next move that belongs to this sequence
	if previous_move.has("sequence_name"):
# Check if move has sequence keys
			for move in move_set:
				if  move_set[move].has("sequence_name"):
# We need move that belongs to choosen sequence and and is next compared to previous move
					if ( move_set[move].sequnce_name == previous_move.sequnce_name) and (  move_set[move].sequence_number == (previous_move.sequence_number + 1) ):
						current_move =  move_set[move]
						return
# If previous move wasn't part of sequence tkae random non-sequence move or first move of any sequence
# according to thier probability weight 
	if current_move.is_empty():
		var probabilty: PackedFloat32Array    # Array that represents probabilty weight of given move
		var moves: Array                      # Array that represents of plausible moves
		var rng = RandomNumberGenerator.new()
# If move belongs to sequence and is first step of seqence (sequence_number == 0) we put it in moves
		for move in move_set:
			if move_set[move].has("sequence"):
				if  move_set[move].sequnce_number == 0:
					moves.append(move)
					probabilty.append(move.weight)
# if move doesn't belongs to sequence we put it moves
			else:
				moves.append( move_set[move])
				probabilty.append( move_set[move].weight)
# Choose next move wwisely RNG
		current_move = moves[rng.rand_weighted(probabilty)]
	print("asdgg2q234 ")


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		BattleHandler.enemies.append(self)
		start_battle.emit(self)


func animate_move()->void:
	pass
