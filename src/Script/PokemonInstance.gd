class_name PokemonInstance

var data : PokemonData
var level := 5


var moves : Array[CT_data] = []
var movesPP : Dictionary[int, int] = {}
enum Type { AUCUN, NORMAL, FEU, EAU, PLANTE, ELECTRIQUE, GLACE, COMBAT, POISON, SOL, VOL,
	 PSY, INSECTE, ROCHE, SPECTRE, DRAGON, TENEBRES, ACIER, FEE}
var is_wild = false
var pokemon_name : String

var Hp_dict : Dictionary = {
	"current" : 0,
	"max" : 0,
	"ivs" : 0,
	"evs" : 0
}

var Atk_dict : Dictionary = {
	"current" : 0,
	"ratio" : 1,
	"ivs" : 0,
	"evs" : 0
}
var AtkSpe_dict : Dictionary = {
	"current" : 0,
	"ratio" : 1,
	"ivs" : 0,
	"evs" : 0
}
var Def_dict : Dictionary = {
	"current" : 0,
	"ratio" : 1,
	"ivs" : 0,
	"evs" : 0
}
var DefSpe_dict : Dictionary = {
	"current" : 0,
	"ratio" : 1,
	"ivs" : 0,
	"evs" : 0
}
var Speed_dict : Dictionary = {
	"current" : 0,
	"ratio" : 1,
	"ivs" : 0,
	"evs" : 0
}

var base_exp_yield : int
var current_xp : int
var xp_to_next_level : int
var pokemon_type1
var pokemon_type2 
var pokemon_node : PokemonNode
var be_part_of_combat : bool = false
var pokemon_id : int

var status = null
var cfn_turn : int = 0
var turn_under_status : int = 0
var NewMoveToLearn : bool = false


signal hp_changed(current : int, maximum : int)
signal fainted
signal level_up(new_level : int)
signal newLevelupMove(move_id: int)

# Called when the node enters the scene tree for the first time.
func initStats(custom_moves : Array = []):
	print(data)
	if Hp_dict["max"] == 0 :
		pokemon_id = data.pokemon_id
		base_exp_yield = data.base_exp_yield
		pokemon_type1 = data.pokemon_type1
		pokemon_type2 = data.pokemon_type2
		pokemon_name = data.pokemon_name
		setup_random_ivs()
		Hp_dict["max"] = calculateStat(data.baseHp, level, Hp_dict["ivs"], true)
		Hp_dict["current"] = Hp_dict["max"]
		if custom_moves.size() > 0 : 
			for move in custom_moves : 
				learnMove(move, 3)
		else : 
			load_moves(data.learnable_moves)
	else:
		var old_max_hp = Hp_dict["max"]
		Hp_dict["max"] = calculateStat(data.baseHp, level, Hp_dict["ivs"], true)
		Hp_dict["current"] = Hp_dict["current"] + (Hp_dict["max"] - old_max_hp)
		
	Atk_dict["current"] = calculateStat(data.baseAtk, Atk_dict["ivs"], level)
	AtkSpe_dict["current"] = calculateStat(data.baseSpeAtk, AtkSpe_dict["ivs"], level)
	Def_dict["current"] = calculateStat(data.baseDef, Def_dict["ivs"], level)
	DefSpe_dict["current"] = calculateStat(data.baseSpeDef, DefSpe_dict["ivs"], level)
	Speed_dict["current"] = calculateStat(data.baseSpd, Speed_dict["ivs"], level)
	current_xp = 0
	xp_to_next_level = get_total_xp_for_level(level + 1) - get_total_xp_for_level(level)

func setup_random_ivs():
	Hp_dict["ivs"] = randi() % 31
	Atk_dict["ivs"] = randi() % 31
	AtkSpe_dict["ivs"] = randi() % 31
	Def_dict["ivs"] = randi() % 31
	DefSpe_dict["ivs"] = randi() % 31
	Speed_dict["ivs"] = randi() % 31
	
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
	
func calculateStat(base : int, lvl : int, IVS : int,  is_hp : bool = false ) -> int :
	# Formule simplifiée : ((2 * Base + 31) * Level) / 100 + modifier
	
	var stat = floor(((2 * base + IVS) * lvl) / 100)
	
	if is_hp :
		return stat + lvl + 10
	return stat + 5

func CenterHealing():
	Hp_dict["current"] = Hp_dict["max"]
	status = null
	for move in moves : 
		movesPP[move.id] = move["max_pp"]
	
func take_damage(damage : int):
	Hp_dict["current"] = max(0, Hp_dict["current"] - damage)
	hp_changed.emit(Hp_dict["current"], Hp_dict["max"])
	await pokemon_node.flash_color(Color.WHITE, 0.4)
	
	if Hp_dict["current"] <= 0:
		faint()

func heal(amount : int):
	Hp_dict["current"] = min(Hp_dict["max"], Hp_dict["current"] + amount)
	hp_changed.emit(Hp_dict["current"], Hp_dict["max"])

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
				NewMoveToLearn = true
	
func lvl_up():
	level += 1
	initStats()
	checkNewMove()
	#level_up.emit(level)

func use_item(item_data : Item_data) -> bool :
	match item_data.effect :
		Item_data.ItemEffect.PVHEAL :
			if Hp_dict["current"] >= Hp_dict["max"]:
				DialogueManager.startDialogue("Cela n'aura aucun effet")
				return false
			else  :
				heal(int(item_data.effect_power))
				DialogueManager.startDialogue("%s est soigné de % Hp." % [pokemon_name, item_data.effect_power])
				return true
	return false
