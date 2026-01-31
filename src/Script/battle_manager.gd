extends Node
class_name Battlemanager

enum battleState {INTRO, PLAYER_TURN, ENEMY_TURN, MOVE_SELECTION,
	ANIMATION, DIALOG, CATCH, VICTORY, DEFEAT, ESCAPE}
	
enum actionType {FIGHT, POKEMON, BAG, RUN}

#signal battle_started(player_pokemon : PokemonInstance, enemy_pokemon : PokemonInstance)
signal turn_started(is_player_turn : bool)
signal move_used(attacker : PokemonInstance, defender : PokemonInstance, move : String) # was dictionnary for claude
signal damage_dealt(target : PokemonInstance, damage : int)
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
var player_pokemon_node
var enemy_pokemon_node
var current_state : battleState = battleState.INTRO
var last_state : battleState = battleState.INTRO
var turn_queue : Array[Dictionary] = []
var battle_text_queue : Array[String] = []

var is_processing_text := false
var is_processing_turn := false

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
	#debug
	print(self)
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

	player_team = player_team_data
	player_pokemon = player_team[0]
	player_pokemon.be_part_of_combat = true
	
	enemy_team = enemy_team_data
	enemy_pokemon = enemy_team[0]
	
	player_pokemon_node = preload("res://src/node/pokemon_node.tscn").instantiate()
	enemy_pokemon_node = preload("res://src/node/pokemon_node.tscn").instantiate()
	
	if Trainer :
		EnemyTrainer = Trainer
		is_wild_battle = false
	
	setup_new_pokemon_node(player_pokemon, true)
	setup_new_pokemon_node(enemy_pokemon, false)
	
	player_pokemon.pokemon_node = player_pokemon_node
	enemy_pokemon.pokemon_node = enemy_pokemon_node
	ui_node.action_selected.connect(_on_action_selected)
	ui_node.move_selected.connect(_on_move_selected)
	
	#ui_node.setup(player_pokemon, enemy_pokemon)
	player_pokemon.connect("newLevelupMove", showMoveLearning)
	current_state = battleState.INTRO
	
	show_intro_animation()

func show_intro_animation():
	var enemy_name = enemy_pokemon.pokemon_name
	if is_wild_battle :
		_queue_text("Un %s sauvage apparaît !" % enemy_name)
	else:
		_queue_text("Le dresseur envoie %s !" % enemy_name)
	await ui_node.animStep
	await _process_text_queue()
	_queue_text("Allez, %s !" % player_pokemon.pokemon_name)
	await _process_text_queue()
	await ui_node.animStep
	turn_started.emit(true)
	current_state = battleState.PLAYER_TURN
	ui_node.show_main_menu()

func _start_player_turn():
	_queue_text("Que va faire %s ?" % player_pokemon.pokemon_name)
	await _process_text_queue()
	
	current_state = battleState.PLAYER_TURN
	turn_started.emit(true)
	ui_node.show_main_menu()
	
	
func start_enemy_turn():
	current_state = battleState.ENEMY_TURN
	turn_started.emit(false)
	
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
			#ui.show_pokemon_menu(player_team)
			return
		actionType.BAG:
			#ui.show_bag_menu()
			return
		actionType.RUN :
			ui_node.hide_move()
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
	print("move used : ", move)
	ui_node.hide_move()
	ui_node.show_text()
	turn_queue.clear()
	_queue_turn(player_pokemon, enemy_pokemon, move)
	_queue_turn(enemy_pokemon, player_pokemon, null)
	await _process_turn_queue()

func _queue_turn(attacker: PokemonInstance, defender: PokemonInstance, move: CT_data):
	var priority = move.priority if move else 0
	turn_queue.append({
		"attacker": attacker,
		"defender": defender,
		"move": move,
		"priority": priority,
		"speed": attacker.current_speed,
		"speed_ratio" : attacker.speed_ratio
	})

func _process_turn_queue():
	if turn_queue.is_empty():
		return
	turn_queue.sort_custom(func(a, b):
		if a.priority != b.priority:
			return a.priority > b.priority
		return ( a.speed * a.speed_ratio ) > (b.speed * b.speed_ratio)
	)
	
	execute_next_turn()
	
func execute_next_turn():
	#j'aime pas bizarre  ?
	if turn_queue.is_empty():
		_start_player_turn()
		return
	var turn_data = turn_queue.pop_front()
	
	if turn_data.attacker.current_hp <= 0:
		execute_next_turn()
		return
	
	print("data move du tour : ", turn_data.move)
	if turn_data.move:
		execute_move(turn_data.attacker, turn_data.defender, turn_data.move)
	else:
		#var available_moves = turn_data.attacker.moves.filter(func(m): return m.pp > 0)
		var available_moves = checkforAvailableMove(turn_data.attacker)
		if available_moves.is_empty():
			use_struggle(turn_data.attacker, turn_data.defender)
		else:
			#logique ia implementer ici 
			var move = available_moves.pick_random()
			execute_move(turn_data.attacker, turn_data.defender, move)

func checkforAvailableMove(pokemon : PokemonInstance) -> Array:
	var available_moves = []
	for i in pokemon.moves.size():
		if pokemon.movesPP[pokemon.moves[i].id] > 0:
			available_moves.append(pokemon.moves[i])
	return available_moves
			
func execute_move(attacker : PokemonInstance, defender : PokemonInstance, move : CT_data):
	current_state = battleState.ANIMATION
	move_used.emit(attacker, defender, move)
	
	var attacker_name = attacker.pokemon_name
	_queue_text("%s utilise %s !" % [attacker_name, move.name])
	
	#move.pp -= 1
	attacker.movesPP[move.id] -= 1
	var accuracy = move.accuracy
	if randf() * 100 > accuracy:
		_queue_text("L'attaque échoue !")
		await _process_text_queue()
		execute_next_turn()
		return
	play_attack_animation(attacker, move)
	#await animation_player.animation_finished
	print("move used : ", move)
	if move.category == "PHYSICS" or move.category == "SPECIAL":
		print("calcul des degats ??")
		var damage = calculate_damage(attacker, defender, move)
		apply_damage(defender, damage)
		
		var effectiveness = get_type_effectiveness(type_to_string(move.type), defender.pokemon_type1, defender.pokemon_type2)
		print("effectiveness : ", effectiveness)
		if effectiveness > 1.0:
			_queue_text("C'est super efficace !")
		elif effectiveness < 1.0 and effectiveness > 0:
			_queue_text("Ce n'est pas très efficace...")
		elif effectiveness == 0:
			_queue_text("Ça n'a aucun effet...")
	elif move.category == "STATUS":
		apply_move_effect(move, attacker, defender)
	else :
		push_error("probleme category du move non trouvé", move)
	await _process_text_queue()
	
	if defender.current_hp <= 0:
		_handle_faint(defender)
	else:
		execute_next_turn()
			
func apply_move_effect(move : CT_data, attacker : PokemonInstance, defender : PokemonInstance) -> bool:
	if move.type_effect == move.Effect.NONE :
		return false
	
	if randi() % 100 >= move.chance:
		return false
	
	#REVOIR POUR ADMETTRE LES TARGETS DE MANIERE PLUS REFLECHIS
	match move.type_effect :
		CT_data.Effect.BURN :
			move_effect_manager.apply_burn(defender)
			_queue_text("%s est desormais brulé : " % defender.pokemon_name)
		CT_data.Effect.LOWER_ENEMY_ATK :
			move_effect_manager.lower_target_atk(defender, move.power_effect)
			_queue_text("l'attaque de %s baisse !" % defender.pokemon_name)
		CT_data.Effect.BOOST_TARGET_ATK :
			move_effect_manager.boost_target_atk(attacker, move.power_effect)
	
	return true
				
# === CALCUL DES DÉGÂTS ===
func calculate_damage(attacker : PokemonInstance, defender : PokemonInstance, move : CT_data) -> int :
	var level = attacker.level
	var power = move.power
	var attack_stat = (attacker.current_atk * attacker.atk_ratio) if move.category == "PHYSICS" else (attacker.current_atkSpe * attacker.atkSpe_ratio)
	var defense_stat = (defender.current_def * defender.def_ratio) if move.category == "PHYSICS" else (defender.current_defSpe * defender.defSpe_ratio)
	print("MON ATTAQUE STAT = ", attack_stat)
	var damage = ((2.0 * level / 5.0 + 2) * power * attack_stat / defense_stat) / 50 + 2.0
	if move.type == attacker.pokemon_type1 or move.type == attacker.pokemon_type2 :
		damage *= 1.5
	
	var effectiveness = get_type_effectiveness(type_to_string(move.type), defender.pokemon_type1, defender.pokemon_type2)
	damage *= effectiveness
	
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
	print("attack type = ", attack_type)
	print("def_type 1 : ", def_type1)
	print("def_type 2 : ", def_type2)
	var strdef_type1 = type_to_string(def_type1)
	var strdef_type2 = type_to_string(def_type2)
	if TYPE_CHART.has(attack_type):
		if TYPE_CHART[attack_type].has(strdef_type1):
			multiplier *= TYPE_CHART[attack_type][strdef_type1]
		if def_type2 and TYPE_CHART[attack_type].has(strdef_type2):
			multiplier *= TYPE_CHART[attack_type][strdef_type2]
	return multiplier

func apply_damage(target : PokemonInstance, damage : int):
	target.take_damage(damage)
	damage_dealt.emit(target, damage)
	var allyornot
	if target == enemy_pokemon :
		allyornot = false
	else :
		allyornot = true
	ui_node.update_hp_bar(allyornot, target)

func _handle_faint(pokemon : PokemonInstance):
	pokemon_fainted.emit(pokemon)
	_queue_text("%s est K.O. !" % pokemon.pokemon_name)
	await _process_text_queue()
	await play_faint_animation(pokemon)
	var checkTeam 
	var isPlayerTeam : bool = false
	if pokemon == player_pokemon :
		checkTeam = player_team
		isPlayerTeam = true
	else :
		checkTeam = enemy_team
		isPlayerTeam = false
	var available_pokemon = checkTeam.filter(func(p): return p.current_hp > 0)
	if available_pokemon.is_empty():
		if isPlayerTeam :
			_end_battle(false)
			return
		else :
			print("handle victory pls ")
			_handle_victory()
			return
	else:
		if isPlayerTeam :
			print("player need to choose new pokemon")
			_end_battle(false)
			return
			#ui_node.show_pokemon_menu(available_pokemon, true) #A DEV
		else:
			enemy_pokemon = available_pokemon.pick_random()
			setup_new_pokemon_node(enemy_pokemon, false)
			_queue_text("Trainer %s envoie %s !" % [EnemyTrainer.interactRange.dialogue_id, enemy_pokemon.pokemon_name])
			await _process_text_queue()
			execute_next_turn()
			
			#logique IA de choix de pokemon a implementer
			
func setup_new_pokemon_node(pokemoninstance : PokemonInstance, is_ally : bool) :
	var newPokemonNode : PokemonNode
	newPokemonNode = preload("res://src/node/pokemon_node.tscn").instantiate()
	newPokemonNode.setup(pokemoninstance)
	newPokemonNode.scale = Vector2(2, 2)
	pokemoninstance.pokemon_node = newPokemonNode
	if is_ally : 
		newPokemonNode.scale = Vector2(2, 2)
		player_pokemon_node = newPokemonNode
		ui_node.PlayerpokemonContainer.add_child(player_pokemon_node)
		player_pokemon_node.animatedSprite.play("back")
		player_pokemon_node.global_position = player_pokemon_position
		ui_node.setup(player_pokemon, null)
	else  :
		newPokemonNode.scale = Vector2(1.5, 1.5)
		enemy_pokemon_node = newPokemonNode
		ui_node.EnemypokemonContainer.add_child(enemy_pokemon_node)
		enemy_pokemon_node.animatedSprite.play("idle")
		enemy_pokemon_node.global_position = enemy_pokemon_position
		ui_node.setup(null, enemy_pokemon)
	
	print("new enemy pokemon node : ", enemy_pokemon_node)
	
		
var hasLeveledUp: bool = false
var newMoveID: int = 0

func _handleLvlUpNewMoveUI() -> void:
	var choice : Array = []
	var move : CT_data = Game.get_move_data(newMoveID)
	while hasLeveledUp:
		ui_node.move_menu.visible = false
		_queue_text("%s veut apprendre %s." % [player_pokemon.pokemon_name, move.name])
		await _process_text_queue()
		choice = await ui_node.askCustomQuestionForLvlUp("Veut tu apprendre cette capacite ?", player_pokemon, newMoveID)
		print("DEBUG : CHOICE : ", choice)
		if choice[0] == true:
			hasLeveledUp = false
			ui_node.text_box.visible = true
		else:
			ui_node.text_box.visible = true
			ui_node.move_menu.visible = true
			ui_node.text_box.visible = true
	if choice[0] == true:
		if choice[1] != null:
			_queue_text("%s a apris %s et ..." % [player_pokemon.pokemon_name, move.name])
			_queue_text("... il a completement oublie %s" % choice[1].name)
		else:
			_queue_text("%s n'a pas apris %s." % [player_pokemon.pokemon_name, move.name])
	else:
		_queue_text("%s n'a pas apris %s." % [player_pokemon.pokemon_name, move.name])
	await _process_text_queue()

func _handle_victory():
	var exp_gained = calculate_exp_gain()
	_queue_text("%s gagne %d points d'expérience !" % [player_pokemon.pokemon_name, exp_gained])
	await _process_text_queue()
	await ui_node.update_xp_bar(player_pokemon, exp_gained)
	await _handleLvlUpNewMoveUI()

	_end_battle(true)

func pokemon_participant():
	var incr = 0
	for poke in player_team:
		print("poke part of combat : ? ", poke.be_part_of_combat)
		if poke.be_part_of_combat == true :
			incr+=1
			poke.be_part_of_combat = false
	return incr
			
func calculate_exp_gain()-> int :
	# ΔEXP=b×L7×1s×e×a×t. 
	# formule simplifié
	var base_exp = enemy_pokemon.base_exp_yield
	var exp_yield =  float(base_exp * enemy_pokemon.level) / 6
	var share_xp = 1 / pokemon_participant()
	var is_trainer_pokemon = 1.5 if not enemy_pokemon.is_wild else 1.0
	return int(exp_yield * share_xp * 1 * is_trainer_pokemon * 1)

func _end_battle(player_won : bool):
	current_state = battleState.VICTORY if player_won else battleState.DEFEAT
	battle_ended.emit(player_won)
	
	
	print(self)
	await Game.get_tree().create_timer(2.0).timeout
	ui_node.queue_free()
	resetBattleManager()
	playerManager.activatePlayer()
	queue_free()

func attempt_escape():
	if not is_wild_battle :
		_queue_text("Impossible de fuir un combat de dresseur !")
		await _process_text_queue()
		return
	
	var escape_chance = (player_pokemon.current_speed * 128) / (enemy_pokemon.current_speed + 1) + 30
	if randf() * 256 < escape_chance:
		_queue_text("Vous avez réussi à fuir !")
		await _process_text_queue()
		_end_battle(false)
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

func play_faint_animation(pokemon: PokemonInstance):
	print("pokemon play faint : ")
	pokemon.faint()

func play_attack_animation(attacker: PokemonInstance, _move: CT_data):
	var current : PokemonNode
	var other : PokemonNode
	print(attacker)
	print("it is wild : ", attacker.is_wild)
	if attacker == player_pokemon:
		current = player_pokemon_node
		other = enemy_pokemon_node
	else :
		current = enemy_pokemon_node
		other = player_pokemon_node
	ui_node.Play_attack_anim(current, other, _move)

func _process(_delta: float) -> void:
	pass

func showMoveLearning(_moveID: int) -> void:
	print("Hello ID: ", _moveID)
	newMoveID = _moveID
	hasLeveledUp = true
	
