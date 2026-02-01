extends Node
class_name MoveEffectManager

const STAT_STAGES := [0.33, 0.37, 0.42, 0.5, 0.6, 0.75, 1.0, 1.33, 1.66, 2.0, 2.3, 2.6, 3.0]
var battleManager : Battlemanager

func set_battleManager(battle_manager : Battlemanager):
	battleManager = battle_manager


func process_end_of_turn_effect(player_pokemon : PokemonInstance, enemy_pokemon : PokemonInstance):
	if player_pokemon.status != null : 
		await process_damage_effect(player_pokemon, player_pokemon.status)
	if enemy_pokemon.status != null :
		await process_damage_effect(enemy_pokemon, enemy_pokemon.status)

func process_incapacity_status(pokemon : PokemonInstance) -> bool :
	match pokemon.status :
		"PARA" :
			if 0.25 <= randf() :
				battleManager._queue_text("%s est paralysé et n'a pas reussi a attaqué..." % pokemon.pokemon_name)
				return true
	return false

func process_damage_effect(pokemon : PokemonInstance, statusType : String):
	match statusType :
		"BRN" :
			battleManager.apply_damage(pokemon, (pokemon.max_hp / 16))
			battleManager._queue_text("%s souffre de sa brulure !" % pokemon.pokemon_name)
		
func apply_burn(target_pokemon : PokemonInstance):
	if target_pokemon.status != null :
		battleManager._queue_text("%s est deja victime de status" % target_pokemon.pokemon_name)
		return
	target_pokemon.status = "BRN"
	target_pokemon.pokemon_node.apply_status_in_Ui(target_pokemon.status)
	battleManager._queue_text("%s est desormais brulé !" % target_pokemon.pokemon_name)

func apply_para(target_pokemon : PokemonInstance):
	if target_pokemon.status != null :
		battleManager._queue_text("%s est deja victime de status" % target_pokemon.pokemon_name)
		return
	target_pokemon.status = "PARA"
	target_pokemon.pokemon_node.apply_status_in_Ui(target_pokemon.status)
	battleManager._queue_text("%s est desormais paralysé !" % target_pokemon.pokemon_name)
	
func lower_target_atk(target_pokemon : PokemonInstance, power : int):
	if target_pokemon.atk_ratio == STAT_STAGES[0]:
		battleManager._queue_text("l'attaque de %s est deja au minimum" % target_pokemon.pokemon_name)
		return
	target_pokemon.atk_ratio = lower_stat(target_pokemon.atk_ratio, power)
	target_pokemon.pokemon_node.Drop_stat_anim()
	await target_pokemon.pokemon_node.animation_finished
	match power :
		1 :
			battleManager._queue_text("l'attaque de %s baisse !" % target_pokemon.pokemon_name)
		2 :
			battleManager._queue_text("l'attaque de %s baisse enormement!" % target_pokemon.pokemon_name)
			
func boost_target_atk(target_pokemon : PokemonInstance, power : int):
	if target_pokemon.atk_ratio == STAT_STAGES[12]:
		battleManager._queue_text("l'attaque de %s est deja au maximum !" % target_pokemon.pokemon_name)
		return
	target_pokemon.atk_ratio = boost_stat(target_pokemon.atk_ratio, power)
	print("BOOST TARGET RATIO is now at :", target_pokemon.atk_ratio)
	target_pokemon.pokemon_node.Boost_stat_anim()
	await target_pokemon.pokemon_node.animation_finished
	match power :
		1 :
			battleManager._queue_text("l'attaque de %s augmente !" % target_pokemon.pokemon_name)
		2 :
			battleManager._queue_text("l'attaque de %s augmente enormement!" % target_pokemon.pokemon_name)
	
func lower_stat(stat_ratio: float, step : int) -> float:
	# trouver le palier le plus proche
	var idx := find_closest_stage(stat_ratio)
	return STAT_STAGES[max(idx - step, 0)]  # descendre d'un palier

func boost_stat(stat_ratio: float, step : int) -> float:
	var idx := find_closest_stage(stat_ratio)
	return STAT_STAGES[min(idx + step, STAT_STAGES.size() - 1)]  # monter d'un palier

func find_closest_stage(stat_ratio: float) -> int:
	# retourne l'index du palier le plus proche
	var closest_idx := 0
	var min_diff : Variant = abs(stat_ratio - STAT_STAGES[0])
	for i in range(1, STAT_STAGES.size()):
		var diff : Variant = abs(stat_ratio - STAT_STAGES[i])
		if diff < min_diff:
			min_diff = diff
			closest_idx = i
	return closest_idx
