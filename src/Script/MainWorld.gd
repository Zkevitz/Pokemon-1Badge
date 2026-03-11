extends Node2D


const DEBUG_SKIP_INTRO := true

func _ready() -> void:
	Game.current_node = self
	if DEBUG_SKIP_INTRO:
		_debug_set_flags()

func _debug_set_flags() -> void:
	StoryManager.set_flag(StoryManager.Flag.INTRO_DONE)
	StoryManager.set_flag(StoryManager.Flag.HAS_POKEMON)
	var starter = PokemonInstance.new()
	starter.data = Game.get_pokemon_data(1)
	starter.level = 5
	starter.is_wild = false
	starter.initStats()
	playerManager.player_instance.pokemonTeam.append(starter)


#func _exit_tree() -> void:
	#queue_free()
