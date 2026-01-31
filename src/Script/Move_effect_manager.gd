extends Node
class_name MoveEffectManager

const STAT_STAGES := [0.33, 0.37, 0.42, 0.5, 0.6, 0.75, 1.0, 1.33, 1.66, 2.0, 2.3, 2.6, 3.0]

func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	pass

func apply_burn(target_pokemon : PokemonInstance):
	target_pokemon.status = "BRN"
	target_pokemon.pokemon_node.apply_status_in_Ui(target_pokemon.status)
	pass

func lower_target_atk(target_pokemon : PokemonInstance, power : int):
	target_pokemon.atk_ratio = lower_stat(target_pokemon.atk_ratio, power)
	target_pokemon.pokemon_node.Drop_stat_anim()
	await target_pokemon.pokemon_node.animation_finished

func boost_target_atk(target_pokemon : PokemonInstance, power : int):
	target_pokemon.atk_ratio = boost_stat(target_pokemon.atk_ratio, power)
	print("BOOST TARGET RATIO is now at :", target_pokemon.atk_ratio)
	target_pokemon.pokemon_node.Boost_stat_anim()
	await target_pokemon.pokemon_node.animation_finished
	
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
