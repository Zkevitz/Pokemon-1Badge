class_name PokemonInstance

var data : PokemonData
var level := 5


var moves : Array[CT_data] = []
var movesPP : Dictionary[int, int] = {}
enum Type { AUCUN, NORMAL, FEU, EAU, PLANTE, ELECTRIQUE, GLACE, COMBAT, POISON, SOL, VOL,
	 PSY, INSECTE, ROCHE, SPECTRE, DRAGON, TENEBRES, ACIER, FEE}
var is_wild = false
var pokemon_name : String
var current_hp :int 
var max_hp : int
var current_atk : int
var atk_ratio : float = 1
var max_atk : int

var current_atkSpe : int
var atkSpe_ratio : float = 1
var max_atkSpe : int 

var current_def : int
var def_ratio : float = 1
var max_def : int 

var current_defSpe : int
var defSpe_ratio : float = 1
var max_defSpe : int 

var current_speed : int
var speed_ratio : float = 1
var max_speed : int

var base_exp_yield : int
var current_xp : int
var xp_to_next_level : int
var pokemon_type1
var pokemon_type2 
var pokemon_node : PokemonNode
var be_part_of_combat : bool = false
var pokemon_id : int
var status = null

signal hp_changed(current : int, maximum : int)
signal fainted
signal level_up(new_level : int)
signal newLevelupMove(move_id: int)

# Called when the node enters the scene tree for the first time.
func initStats():
	print(data)
	pokemon_id = data.pokemon_id
	base_exp_yield = data.base_exp_yield
	pokemon_type1 = data.pokemon_type1
	pokemon_type2 = data.pokemon_type2
	pokemon_name = data.pokemon_name
	if not max_hp :
		max_hp = calculateStat(data.baseHp, level, true)
		current_hp = max_hp
		load_moves(data.learnable_moves)
		print("DEBUG: Moves[0] : ", moves[0])
	else:
		var old_max_hp = max_hp
		max_hp = calculateStat(data.baseHp, level, true)
		current_hp = current_hp + (max_hp - old_max_hp)
	max_atk = calculateStat(data.baseAtk, level)
	current_atk = max_atk
	max_atkSpe = calculateStat(data.baseSpeAtk, level)
	current_atkSpe = max_atkSpe
	max_def = calculateStat(data.baseDef, level)
	current_def = max_def
	max_defSpe = calculateStat(data.baseSpeDef, level)
	current_defSpe = max_defSpe
	max_speed = calculateStat(data.baseSpd, level)
	current_speed = max_speed
	current_xp = 0
	xp_to_next_level = get_total_xp_for_level(level + 1) - get_total_xp_for_level(level)

func get_total_xp_for_level(actuallevel: int) -> int:
	return int((4.0 * pow(actuallevel, 3)) / 5.0)
	
func load_moves(learnmoves : Array[MoveLearnData]):
	var base_moves := []
	
	for move_data in learnmoves :
		print("MOVE DATA --> ", move_data)
		if move_data.LearnType == 0:
			print("move data PATH ??", move_data.resource_path)
			print("move data ---->>>", move_data.move_id)
			base_moves.append(move_data.move_id)
	
	if base_moves.is_empty():
		return
	base_moves.shuffle()
	var move_count := randi_range(2, min(4, base_moves.size()))
	
	moves.clear()
	for i in range(move_count):
		var loaded_move = base_moves[i]
		var final_move_data = Game.get_move_data(loaded_move)
		print("Final_move_DATA :", final_move_data.power)
		moves.append(final_move_data)
		movesPP[final_move_data.id] = final_move_data.max_pp

func learnMove(moveidx : int, idx : int):
	var final_move_data = Game.get_move_data(moveidx)
	print("Final_move_DATA :!!!!!", final_move_data.power)
	if moves.size() >= 4 :
		moves[idx] = final_move_data
		movesPP[final_move_data.id] = final_move_data.max_pp
	else :
		moves.append(final_move_data)
		movesPP[final_move_data.id] = final_move_data.max_pp
	
func calculateStat(base : int, lvl : int, is_hp : bool = false ) -> int :
	# Formule simplifiée : ((2 * Base + 31) * Level) / 100 + modifier
	
	var stat = ((2 * base + 31) * lvl) / 100
	
	if is_hp :
		return stat + lvl + 10
	return stat + 5

func CenterHealing():
	current_hp = max_hp
	for move in moves : 
		movesPP[move.id] = move["max_pp"]
	
func take_damage(damage : int):
	current_hp = max(0, current_hp - damage)
	hp_changed.emit(current_hp, max_hp)
	
	if current_hp <= 0:
		faint()

func heal(amount : int):
	current_hp = min(max_hp, current_hp + amount)
	hp_changed.emit(current_hp, max_hp)

func faint():
	fainted.emit()
	if pokemon_node :
		pokemon_node.sink_into_ground()
	
func checkNewMove() -> void:
	for i in data.learnable_moves.size():
		if data.learnable_moves[i].LearnType == 1:
			if level == data.learnable_moves[i].LevelRequired:
				if moves.size() <= 3:
					var move = Game.get_move_data(data.learnable_moves[i].move_id)
					moves.append(move)
					movesPP[move.id] = move.max_pp
				else:
					newLevelupMove.emit(data.learnable_moves[i].move_id)
					
	
func lvl_up():
	level += 1
	initStats()
	level_up.emit(level)
	checkNewMove()
