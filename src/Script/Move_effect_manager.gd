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
	var random_chance : float = randf()
	print("random chance from incapacity status : ", random_chance)
	print("pokemon under status turn : ", pokemon.turn_under_status)
	match pokemon.status :
		"PARA" :
			if random_chance <= 0.25 :
				battleManager._queue_text("%s est paralysé et n'a pas reussi a attaqué..." % pokemon.pokemon_name)
				await battleManager._process_text_queue()
				await pokemon.pokemon_node.play_para()
				return true
		"SLEEP" :
			if (0.33 <= random_chance and pokemon.turn_under_status >= 1) or pokemon.turn_under_status >= 3:
				battleManager._queue_text("%s se reveille !" % pokemon.pokemon_name)
				pokemon.pokemon_node.apply_status_in_Ui("")
				pokemon.turn_under_status = 0
				return false
			battleManager._queue_text("%s dors profondement !" % pokemon.pokemon_name)
			await battleManager._process_text_queue()
			await pokemon.pokemon_node.play_sleep()
			pokemon.turn_under_status += 1
			return true
	if pokemon.cfn_turn > 0 :
		pokemon.cfn_turn -= 1
		battleManager._queue_text("%s est confus..." % pokemon.pokemon_name)
		if pokemon.cfn_turn == 0 :
			battleManager._queue_text("%s sort de sa confusion !" % pokemon.pokemon_name)
			return false
		await battleManager._process_text_queue()
		await pokemon.pokemon_node.play_confusion()
		if 0.33 <= random_chance : 
			battleManager._queue_text("%s se frappe dans sa confusion !" % pokemon.pokemon_name)
			var damage = calculate_confusion_damage(pokemon)
			await battleManager._process_text_queue()
			await pokemon.pokemon_node.flash_white()
			battleManager.apply_damage(pokemon, damage)
			return true
		return false
				
	return false

func calculate_confusion_damage(receiver : PokemonInstance) -> int :
	var damage = (((2 * receiver.level / 5 + 2) * 40 * receiver.Atk_dict["current"] / receiver.Def_dict["current"]) / 50) + 2
	return damage
	
func process_damage_effect(pokemon : PokemonInstance, statusType : String):
	match statusType :
		"BRN" :
			await pokemon.pokemon_node.play_burn()
			battleManager.apply_damage(pokemon, max(pokemon.Hp_dict["max"] / 16, 1))
			battleManager._queue_text("%s souffre de sa brulure !" % pokemon.pokemon_name)
		"PSN" :
			SoundManager.play_sfx(preload("res://sound/SFX/status/Status Poison.ogg"), -10)
			await pokemon.pokemon_node.play_poison()
			battleManager.apply_damage(pokemon, (pokemon.Hp_dict["max"] / 8))
			battleManager._queue_text("%s souffre du poison !" % pokemon.pokemon_name)
		
func apply_burn(target_pokemon : PokemonInstance):
	if target_pokemon.status != null :
		battleManager._queue_text("%s est deja victime de status" % target_pokemon.pokemon_name)
		return
	target_pokemon.status = "BRN"
	target_pokemon.pokemon_node.apply_status_in_Ui(target_pokemon.status)
	battleManager._queue_text("%s est desormais brulé !" % target_pokemon.pokemon_name)

func apply_poison(target_pokemon : PokemonInstance) :
	if target_pokemon.status != null : 
		battleManager._queue_text("%s est deja victime de status" % target_pokemon.pokemon_name)
		return
	await target_pokemon.pokemon_node.play_poison()
	target_pokemon.status = "PSN"
	target_pokemon.pokemon_node.apply_status_in_Ui(target_pokemon.status)
	battleManager._queue_text("%s est desormais empoisonné !" % target_pokemon.pokemon_name)
	
func apply_sleep(target_pokemon : PokemonInstance):
	if target_pokemon.status != null : 
		battleManager._queue_text("%s est deja victime de status" % target_pokemon.pokemon_name)
		return
	await target_pokemon.pokemon_node.play_sleep()
	target_pokemon.status = "SLEEP"
	target_pokemon.pokemon_node.apply_status_in_Ui(target_pokemon.status)
	battleManager._queue_text("%s est desormais endormis !" % target_pokemon.pokemon_name)
	
func apply_para(target_pokemon : PokemonInstance):
	if target_pokemon.status != null :
		battleManager._queue_text("%s est deja victime de status" % target_pokemon.pokemon_name)
		return
	await target_pokemon.pokemon_node.play_para()
	target_pokemon.status = "PARA"
	target_pokemon.pokemon_node.apply_status_in_Ui(target_pokemon.status)
	battleManager._queue_text("%s est desormais paralysé !" % target_pokemon.pokemon_name)

func apply_confusion(target_pokemon : PokemonInstance):
	if target_pokemon.cfn_turn > 0 :
		battleManager._queue_text("%s est deja confus..." % target_pokemon.pokemon_name)
		return
	target_pokemon.cfn_turn = (randi() % 2) + 2;
	print("choose pokemon confusion turn : ", target_pokemon.cfn_turn)
	await target_pokemon.pokemon_node.play_confusion()
	battleManager._queue_text("%s est desormais confus !" % target_pokemon.pokemon_name)
	
func lower_target_atk(target_pokemon : PokemonInstance, power : int):
	if target_pokemon.Atk_dict["ratio"] == STAT_STAGES[0]:
		battleManager._queue_text("l'attaque de %s est deja au minimum" % target_pokemon.pokemon_name)
		return
	target_pokemon.Atk_dict["ratio"] = lower_stat(target_pokemon.Atk_dict["ratio"], power)
	target_pokemon.pokemon_node.Drop_stat_anim()
	SoundManager.play_sfx(preload("res://sound/SFX/status/Stat Down.ogg"), -10)
	await target_pokemon.pokemon_node.animation_finished
	match power :
		1 :
			battleManager._queue_text("l'attaque de %s baisse !" % target_pokemon.pokemon_name)
		2 :
			battleManager._queue_text("l'attaque de %s baisse enormement!" % target_pokemon.pokemon_name)
			
func boost_target_atk(target_pokemon : PokemonInstance, power : int):
	if target_pokemon.Atk_dict["ratio"] == STAT_STAGES[12]:
		battleManager._queue_text("l'attaque de %s est deja au maximum !" % target_pokemon.pokemon_name)
		return
	target_pokemon.Atk_dict["ratio"] = boost_stat(target_pokemon.Atk_dict["ratio"], power)
	print("BOOST TARGET RATIO is now at :", target_pokemon.Atk_dict["ratio"])
	target_pokemon.pokemon_node.Boost_stat_anim()
	SoundManager.play_sfx(preload("res://sound/SFX/status/Stat Up.ogg"), -10)
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
