extends Node
class_name Battlemanager

enum battleState {INTRO, PLAYER_TURN, ENEMY_TURN, MOVE_SELECTION, POKEMON_SELECTION,
	ANIMATION, DIALOG, CATCH, VICTORY, DEFEAT, ESCAPE}
	
enum actionType {FIGHT, POKEMON, BAG, RUN ,IA}

#signal turn_started(is_player_turn : bool)
#signal damage_dealt(target : PokemonInstance, damage : int)
signal pokemon_fainted(pokemon : PokemonInstance)
signal battle_ended(player_won : bool)


var ui_node : BattleUI
var move_effect_manager : MoveEffectManager

var player_pokemon_position := Vector2(302.0, 404.0)
var enemy_pokemon_position := Vector2(800.0, 203.0)

var player_pokemon : PokemonInstance
var enemy_pokemon : PokemonInstance

var player_team : Array[PokemonInstance]
var enemy_team : Array[PokemonInstance]

var is_wild_battle: bool = true
var EnemyTrainer : CharacterBody2D

var current_state : battleState = battleState.INTRO
var last_state : battleState = battleState.INTRO
var turn_queue : Array[Dictionary] = []
var battle_text_queue : Array[String] = []

var is_processing_text := false
var is_processing_turn := false
var newMoveID: int = 0

const CRITICAL_HIT_CHANCE := 0.0625
const TYPE_CHART := {
	# Format: [attaquant][défenseur] = multiplicateur
	"Feu": {"Plante": 2.0, "Eau": 0.5, "Feu": 0.5},
	"Eau": {"Feu": 2.0, "Plante": 0.5, "Eau": 0.5},
	"Plante": {"Eau": 2.0, "Feu": 0.5, "Plante": 0.5},
	"Electrik": {"Eau": 2.0, "Vol": 2.0, "Electrik": 0.5, "Sol": 0.0},
	"Normal": {},
}

func _physics_process(_delta: float) -> void:
	if current_state != last_state :
		last_state = current_state
		print("battle state is on", current_state)
	
func _ready() -> void:
	pass
	
func resetBattleManager():
	current_state = battleState.INTRO
	turn_queue = []
	battle_text_queue  = []
	player_team = []
	enemy_team = []
	
func start_battle(player_team_data : Array[PokemonInstance], enemy_team_data : Array[PokemonInstance], Trainer : CharacterBody2D = null):
	ui_node = Game.battle_ui
	move_effect_manager = MoveEffectManager.new()
	move_effect_manager.set_battleManager(self)

	player_team = player_team_data
	player_pokemon = player_team[0]
	player_pokemon.be_part_of_combat = true
	
	enemy_team = enemy_team_data
	enemy_pokemon = enemy_team[0]
	
	if Trainer :
		EnemyTrainer = Trainer
		is_wild_battle = false
	
	setup_new_pokemon_node(player_pokemon, true)
	setup_new_pokemon_node(enemy_pokemon, false)

	ui_node.action_selected.connect(_on_action_selected)
	ui_node.move_selected.connect(_on_move_selected)
	ui_node.pokemon_selected.connect(_on_pokemon_selected)
	
	player_pokemon.connect("newLevelupMove", showMoveLearning)
	current_state = battleState.INTRO
	
	show_intro_animation()

func show_intro_animation():
	var enemy_name = enemy_pokemon.pokemon_name
	if is_wild_battle :
		_queue_text("Un %s apparaît !" % enemy_name)
	else:
		_queue_text("Le dresseur envoie %s !" % enemy_name)
	await ui_node.animStep
	await _process_text_queue()
	_queue_text("Allez, %s !" % player_pokemon.pokemon_name)
	await _process_text_queue()
	await ui_node.animStep
	#turn_started.emit(true)
	current_state = battleState.PLAYER_TURN
	ui_node.show_main_menu(true)

func _start_player_turn():
	_queue_text("Que va faire %s ?" % player_pokemon.pokemon_name)
	await _process_text_queue()
	ui_node.show_main_menu(true)
	
	current_state = battleState.PLAYER_TURN
	#turn_started.emit(true)
	
	
func start_enemy_turn():
	current_state = battleState.ENEMY_TURN
	#turn_started.emit(false)
	
	await Game.get_tree().create_timer(0.5).timeout
	var available_moves = checkforAvailableMove(enemy_pokemon)
	if available_moves.is_empty():
		use_struggle(enemy_pokemon, player_pokemon)
	else:
		var move = available_moves.pick_random()
		execute_move(enemy_pokemon, player_pokemon, move)
	

func _on_action_selected(action : actionType):
	print("currentstate : ", current_state)
	if current_state != battleState.PLAYER_TURN :
		return
	match action:
		actionType.FIGHT:
			ui_node.show_move_menu(player_pokemon)
		actionType.POKEMON:
			ui_node.show_pokemon_menu(player_team)
			return
		actionType.BAG:
			#ui.show_bag_menu()
			return
		actionType.RUN :
			ui_node.show_move(false)
			ui_node.show_pokemon(false)
			attempt_escape()

func _on_move_selected(move_index : int):
		
	current_state = battleState.MOVE_SELECTION
	var move = player_pokemon.moves[move_index]
	
	if player_pokemon.movesPP[move.id] <= 0:
		_queue_text("Plus de PP pour cette attaque !")
		await _process_text_queue()
		current_state = battleState.PLAYER_TURN
		ui_node.show_move_menu(player_pokemon)
		return
		
	ui_node.show_main_menu(false)
	ui_node.show_move(false)
	ui_node.show_text(true)
	
	turn_queue.clear()
	_queue_turn(player_pokemon, enemy_pokemon, actionType.FIGHT,  move)
	_queue_turn(enemy_pokemon, player_pokemon, actionType.IA, null)
	await _process_turn_queue()

func _on_pokemon_selected(pokemon_index : int):
	current_state = battleState.POKEMON_SELECTION
	var pokemon = player_team[pokemon_index]
	
	ui_node.show_main_menu(false)
	ui_node.show_move(false)
	ui_node.show_pokemon(false)
	ui_node.show_text(true)
	
	turn_queue.clear()
	_queue_turn(pokemon, enemy_pokemon, actionType.POKEMON)
	_queue_turn(enemy_pokemon, player_pokemon, actionType.IA, null)
	await _process_turn_queue()
	
func _queue_turn(attacker: PokemonInstance, defender: PokemonInstance, action : actionType ,move: CT_data = null):
	var priority = move.priority if move else 0
	turn_queue.append({
		"attacker": attacker,
		"defender": defender,
		"action" : action,
		"move": move,
		"priority": priority,
		"speed": attacker.Speed_dict["current"],
		"speed_ratio" : attacker.Speed_dict["ratio"]
	})

func _process_turn_queue():
	if turn_queue.is_empty():
		return
	turn_queue.sort_custom(func(a, b):
		if a.action == actionType.POKEMON and b.action != actionType.POKEMON:
			return true
		if b.action == actionType.POKEMON and a.action != actionType.POKEMON:
			return false
		if a.priority != b.priority:
			return a.priority > b.priority
		return ( a.speed * a.speed_ratio ) > (b.speed * b.speed_ratio)
	)
	execute_next_turn()
	
func execute_next_turn():
	if turn_queue.is_empty():
		push_error("est ce que je passe la dedans battle manager bizarre")
		await move_effect_manager.process_end_of_turn_effect(player_pokemon, enemy_pokemon)
		if player_pokemon.Hp_dict["current"] <= 0 :
			await _handle_faint(player_pokemon)
			return
		elif enemy_pokemon.Hp_dict["current"] <= 0 :
			await _handle_faint(enemy_pokemon)
			return
		_start_player_turn()
		return
	var turn_data = turn_queue.pop_front()
	
	#ME SEMBLE USELESS
	#if turn_data.attacker.Hp_dict["current"] <= 0:
		#execute_next_turn()
		#return
	if turn_data.action == actionType.POKEMON :
		await switch_pokemon(turn_data)
		return
	if turn_data.move:
		execute_move(turn_data.attacker, turn_data.defender, turn_data.move)
	else:
		var available_moves = checkforAvailableMove(turn_data.attacker)
		if available_moves.is_empty():
			use_struggle(turn_data.attacker, turn_data.defender)
		else:
			#logique ia implementer ici 
			var move = available_moves.pick_random()
			execute_move(turn_data.attacker, turn_data.defender, move)

func switch_pokemon(turn_data : Dictionary):
	var attacker : PokemonInstance = turn_data["attacker"]
	var is_opponent = attacker.pokemon_node.is_opponent
	
	var pokemon_to_switch : PokemonInstance
	var trainer_name : String
	if is_opponent :
		pokemon_to_switch = enemy_pokemon
		trainer_name = "{nom du dresseur}"
	else :
		pokemon_to_switch = player_pokemon
		trainer_name = "{nom du joueur}"
	
	_queue_text("%s retire %s" % [trainer_name, pokemon_to_switch.pokemon_name])
	await  _process_text_queue()
	
	await pokemon_to_switch.pokemon_node.fight_exit()
	
	if is_opponent:
		enemy_pokemon = attacker
	else : 
		player_pokemon = attacker
	_queue_text("%s envoie %s" % [trainer_name, attacker.pokemon_name])
	await _process_text_queue()
	setup_new_pokemon_node(attacker, !is_opponent)
	for queu in turn_queue :
		if queu["attacker"] == pokemon_to_switch :
			queu["attacker"] = attacker
		elif queu["defender"] == pokemon_to_switch :
			queu["defender"] = attacker
	await get_tree().create_timer(0.5).timeout
	execute_next_turn()
	
func checkforAvailableMove(pokemon : PokemonInstance) -> Array:
	var available_moves = []
	for i in pokemon.moves.size():
		if pokemon.movesPP[pokemon.moves[i].id] > 0:
			available_moves.append(pokemon.moves[i])
	return available_moves
			
func execute_move(attacker : PokemonInstance, defender : PokemonInstance, move : CT_data):
	current_state = battleState.ANIMATION
	
	var attacker_name = attacker.pokemon_name
	_queue_text("%s utilise %s !" % [attacker_name, move.name])
	
	if attacker.status != null or attacker.cfn_turn > 0: 
		var result = await move_effect_manager.process_incapacity_status(attacker)
		if result :
			await _process_text_queue()
			if attacker.Hp_dict["current"] <= 0 :
				await _handle_faint(attacker)
				return
			execute_next_turn()
			return
			
	attacker.movesPP[move.id] -= 1
	var accuracy = move.accuracy
	if randf() * 100 > accuracy:
		_queue_text("L'attaque échoue !")
		await _process_text_queue()
		execute_next_turn()
		return
	
	
	await _process_text_queue()
	await play_attack_animation(attacker, defender, move)
	#await animation_player.animation_finished
	print("move used : ", move)
	var effectiveness = get_type_effectiveness(type_to_string(move.type), defender.pokemon_type1, defender.pokemon_type2)
	if effectiveness == 0.0 : 
		_queue_text("%s est imunisé !")
	else : 
		# a changer pour faire fonctionner les move degats + status
		if move.category == "PHYSICS" or move.category == "SPECIAL":
			print("calcul des degats ??")
			var damage = calculate_damage(attacker, defender, move, effectiveness)
			await apply_damage(defender, damage, effectiveness)
			
		elif move.category == "STATUS":
			await apply_move_effect(move, attacker, defender)
		else :
			push_error("probleme category du move non trouvé", move)
			
	await _process_text_queue()
	await Game.get_tree().create_timer(0.5).timeout
	if defender.Hp_dict["current"] <= 0:
		await _handle_faint(defender)
	else:
		execute_next_turn()
			
func apply_move_effect(move : CT_data, attacker : PokemonInstance, defender : PokemonInstance) -> bool:
	if move.type_effect == move.Effect.NONE :
		return false
	
	if randi() % 100 >= move.chance:
		return false
		
	#REVOIR POUR ADMETTRE LES TARGETS DE MANIERE PLUS REFLECHIS
	match move.type_effect :
		CT_data.Effect.CFN :
			await move_effect_manager.apply_confusion(defender)
		CT_data.Effect.PSN :
			await move_effect_manager.apply_poison(defender)
		CT_data.Effect.BURN :
			move_effect_manager.apply_burn(defender)
		CT_data.Effect.PARA :
			await move_effect_manager.apply_para(defender)
		CT_data.Effect.SLEEP :
			await move_effect_manager.apply_sleep(defender)
		CT_data.Effect.LOWER_ENEMY_ATK :
			await move_effect_manager.lower_target_atk(defender, move.power_effect)
		CT_data.Effect.BOOST_TARGET_ATK :
			await move_effect_manager.boost_target_atk(attacker, move.power_effect)
	
	await _process_text_queue()
	return true
				
# === CALCUL DES DÉGÂTS ===
func calculate_damage(attacker : PokemonInstance, defender : PokemonInstance, move : CT_data, effectiveness : float) -> int :
	var level = attacker.level
	var power = move.power
	var attack_stat = (attacker.Atk_dict["current"] * attacker.Atk_dict["ratio"]) if move.category == "PHYSICS" else (attacker.AtkSpe_dict["current"] * attacker.AtkSpe_dict["ratio"])
	var defense_stat = (defender.Def_dict["current"] * defender.Def_dict["ratio"]) if move.category == "PHYSICS" else (defender.DefSpe_dict["current"] * defender.DefSpe_dict["ratio"])
	print("MON ATTAQUE STAT = ", attack_stat)
	var damage = ((2.0 * level / 5.0 + 2) * power * attack_stat / defense_stat) / 50 + 2.0
	if move.type == attacker.pokemon_type1 or move.type == attacker.pokemon_type2 :
		damage *= 1.5
	
	damage *= effectiveness
	if effectiveness > 1.0:
		_queue_text("C'est super efficace !")
	elif effectiveness < 1.0 and effectiveness > 0:
		_queue_text("Ce n'est pas très efficace...")
	elif effectiveness == 0:
		_queue_text("Ça n'a aucun effet...")
	
	if randf() < CRITICAL_HIT_CHANCE:
		damage *= 1.5
		_queue_text("Coup Critique !")
		
	damage *= randf_range(0.85, 1.0)
	return max(1, int(damage))
	
func type_to_string(t: int) -> String:
	if t < 0 or t >= PokemonInstance.Type.size():
		return "Inconnu"
	return PokemonInstance.Type.keys()[t].capitalize()

func get_type_effectiveness(attack_type : String, def_type1 : PokemonInstance.Type, def_type2 : PokemonInstance.Type):
	var multiplier = 1.0
	
	# DEBUG
	#print("attack type = ", attack_type)
	#print("def_type 1 : ", def_type1)
	#print("def_type 2 : ", def_type2)
	var strdef_type1 = type_to_string(def_type1)
	var strdef_type2 = type_to_string(def_type2)
	if TYPE_CHART.has(attack_type):
		if TYPE_CHART[attack_type].has(strdef_type1):
			multiplier *= TYPE_CHART[attack_type][strdef_type1]
		if def_type2 and TYPE_CHART[attack_type].has(strdef_type2):
			multiplier *= TYPE_CHART[attack_type][strdef_type2]
	return multiplier

func apply_damage(target : PokemonInstance, damage : int, effectiveness : float = 1.0):
	const Sound_damage = {
		2.0 : [
			preload("res://sound/SFX/damageTaken/Battle damage super.ogg") ],
		1.0 : [
			preload("res://sound/SFX/damageTaken/Battle damage normal.ogg") ],
		0.5 : [
			preload("res://sound/SFX/damageTaken/Battle damage weak.ogg") ]
	}
	SoundManager.play_sfx(Sound_damage[effectiveness][0], -10)
	target.take_damage(damage)
	var allyornot
	if target == enemy_pokemon :
		allyornot = false
	else :
		allyornot = true
	await ui_node.update_hp_bar(allyornot, target)
	
func handle_exp_reward():
	var exp_gained = calculate_exp_gain()
	for poke in player_team : 
		print("pokemon : ", poke.pokemon_name, poke.be_part_of_combat)
		if poke.be_part_of_combat == true : 
			_queue_text("%s gagne %d points d'expérience !" % [poke.pokemon_name, exp_gained])
			poke.be_part_of_combat = false
			
			await _process_text_queue()
			await ui_node.update_xp_bar(player_pokemon, exp_gained)
			var choice : Array
			while poke.NewMoveToLearn == true :
				if newMoveID == 0 :
					_queue_text("%s apprend la capacité %s" % [poke.pokemon_name, poke.moves[poke.moves.size() - 1].name]) 
				else :
					_queue_text("%s souhaite apprendre une nouvelle capacité." % player_pokemon.pokemon_name)
					await _process_text_queue()
					var move_data = Game.get_move_data(newMoveID)
					choice = await ui_node.askCustomQuestionForLvlUp("Voulez vous apprendre la capacité %s ?" % move_data.name, player_pokemon, move_data)
					if choice[0] == true and choice[1] == null:
						ui_node.text_box.visible = true
						_queue_text("%s n'a pas appris %s" % [poke.pokemon_name, move_data.name])
						player_pokemon.NewMoveToLearn = false
					elif choice[0] == true and choice[1] :
						ui_node.text_box.visible = true 
						_queue_text("%s oublie %s..." % [poke.pokemon_name, choice[1].name])
						_queue_text("et apprend %s !" % move_data.name)
						player_pokemon.NewMoveToLearn = false
					else:
						ui_node.text_box.visible = true
						ui_node.move_menu.visible = false
				await _process_text_queue()
	
func _handle_faint(pokemon : PokemonInstance):
	for queu in turn_queue : 
		if queu["attacker"] == pokemon :
			turn_queue.erase(queu)
	pokemon_fainted.emit(pokemon)
	_queue_text("%s est K.O. !" % pokemon.pokemon_name)
	await _process_text_queue()
	await pokemon.faint()
	await Game.get_tree().create_timer(0.5).timeout
	if pokemon != player_pokemon : 
		await handle_exp_reward()
		 
	var available_pokemon
	if pokemon == player_pokemon :
		available_pokemon = player_team.filter(func(p): return p.Hp_dict["current"] > 0)
		if available_pokemon.is_empty() :
			_queue_text("{introduire nom du joeur} n'a plus de Pokemon pour se battre")
			_queue_text("{introduire nom du joeur} se hate au Centre Pokemon le plus proche")
			_end_battle(false)
			return
		else :
			_queue_text("Choisissez un pokemon !  ")
			#ui_node.show_pokemon_menu(available_pokemon, true) #A DEV
			_end_battle(false)
			return
	else :
		available_pokemon = enemy_team.filter(func(p): return p.Hp_dict["current"] > 0)
		if available_pokemon.is_empty():
			_end_battle(true)
			return
		else:
			#logique IA de choix pokemon a implementer
			enemy_pokemon = available_pokemon.pick_random()
			setup_new_pokemon_node(enemy_pokemon, false)
			_queue_text("Trainer %s envoie %s !" % [EnemyTrainer.interactRange.dialogue_id, enemy_pokemon.pokemon_name])
			await _process_text_queue()
			execute_next_turn()
			
func setup_new_pokemon_node(pokemoninstance : PokemonInstance, is_ally : bool) :
	var newPokemonNode : PokemonNode
	newPokemonNode = preload("res://src/node/pokemon_node.tscn").instantiate()
	newPokemonNode.setup(pokemoninstance)
	newPokemonNode.scale_value = Vector2(2, 2)
	pokemoninstance.pokemon_node = newPokemonNode
	if is_ally :
		ui_node.PlayerpokemonContainer.add_child(player_pokemon.pokemon_node)
		player_pokemon.pokemon_node.animatedSprite.play("back")
		player_pokemon.pokemon_node.global_position = player_pokemon_position
		ui_node.setup(player_pokemon, null)
	else :
		if is_wild_battle == true :
			pokemoninstance.pokemon_name = pokemoninstance.pokemon_name + " sauvage"
		else :
			pokemoninstance.pokemon_name = pokemoninstance.pokemon_name + " ennemi"
		pokemoninstance.is_wild = true
		enemy_pokemon.pokemon_node.scale_value = Vector2(1.5, 1.5)
		ui_node.EnemypokemonContainer.add_child(enemy_pokemon.pokemon_node)
		enemy_pokemon.pokemon_node.animatedSprite.play("idle")
		enemy_pokemon.pokemon_node.global_position = enemy_pokemon_position
		ui_node.setup(null, enemy_pokemon)
	
	
func pokemon_participant():
	var incr = 0
	for poke in player_team:
		if poke.be_part_of_combat == true :
			incr+=1
	return incr
			
func calculate_exp_gain()-> int :
	# ΔEXP=b×L7×1s×e×a×t. 
	# formule simplifié
	var base_exp = enemy_pokemon.base_exp_yield
	var exp_yield =  float(base_exp * enemy_pokemon.level) / 6
	var share_xp = 1 / max(pokemon_participant(), 1)
	var is_trainer_pokemon = 1.5 if not enemy_pokemon.is_wild else 1.0
	return int(exp_yield * share_xp * 1 * is_trainer_pokemon * 1)

func _end_battle(player_won : bool):
	current_state = battleState.VICTORY if player_won else battleState.DEFEAT
	battle_ended.emit(player_won)
	
	await _process_text_queue()
	ui_node.queue_free()
	resetBattleManager()
	if player_won == false : 
		await playerManager.HealingCenterTp()
	if playerManager.Is_active() == false :
		await playerManager.activatePlayer()
	queue_free()

func attempt_escape():
	ui_node.show_text(true)
	if not is_wild_battle :
		_queue_text("Impossible de fuir un combat de dresseur !")
		await _process_text_queue()
		_start_player_turn()
		return
	
	var escape_chance = (player_pokemon.Speed_dict["current"] * 128) / (enemy_pokemon.Speed_dict["current"] + 1) + 30
	print("ESCAPE CHANCE = ", escape_chance)
	if randf() * 256 < escape_chance:
		_queue_text("Vous avez réussi à fuir !")
		await _process_text_queue()
		ui_node.queue_free()
		resetBattleManager()
		if playerManager.Is_active() == false :
			await playerManager.activatePlayer()
		queue_free()
		
	else:
		_queue_text("Impossible de fuir !")
		await _process_text_queue()
		start_enemy_turn()

func _queue_text(text : String):
	battle_text_queue.append(text)

func _process_text_queue():
	while not battle_text_queue.is_empty():
		current_state = battleState.DIALOG
		var text = battle_text_queue.pop_front()
		ui_node.display_text(text)
		await ui_node.text_finished

func use_struggle(attacker: PokemonInstance, defender: PokemonInstance):
	var struggle_move = {
		"name": "Lutte",
		"power": 50,
		"type": "Normal",
		"pp": 1,
		"accuracy": 100
	}
	execute_move(attacker, defender, struggle_move)
	# Dégâts de recul
	@warning_ignore("integer_division")
	attacker.take_damage(attacker.max_hp / 4)

func play_attack_animation(attacker: PokemonInstance, defender : PokemonInstance, _move: CT_data):
	var attackAnim = null
	print("move animName : ", _move.AnimName)
	if _move.AnimName != "Default" : 
		attackAnim = _move.AnimNode.instantiate()
		ui_node.PlayerpokemonContainer.add_child(attackAnim)
	await ui_node.Play_attack_anim(attacker.pokemon_node, defender.pokemon_node, _move, attackAnim)


func showMoveLearning(_moveID: int) -> void:
	newMoveID = _moveID
