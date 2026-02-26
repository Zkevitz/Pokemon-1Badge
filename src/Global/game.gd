extends Node

const tileSize := 16
var tile_center_offset = Vector2.ONE * tileSize * 0.5
var returnPosition := Vector2.ZERO
var returnScene : Node2D
var actualNode : Node2D
#var toggle_timer := 2.0

var pokemon_by_id: Dictionary = {}
var items_by_id : Dictionary = {}
var move_cache := {}

var GlobalUI : Control 
var battleManager : Battlemanager
var battleui = preload("res://src/node/UI/battle_ui.tscn")
var battle_ui

var current_node : Node2D
var processing_scene_change : bool
var World_Map : WorldMap

enum recompenseType {POKEMON, OBJECT, TEAM_HEALING}

func _ready() -> void:
	_load_all_pokemon()
	_load_all_items()
	print(items_by_id)

func get_move_data(id: int) -> CT_data:
	if not move_cache.has(id):
		var path := "res://src/ressources/CTdata/%d.tres" % id
		move_cache[id] = load(path)
	return move_cache[id]
		
func get_pokemon_data(id: int) -> PokemonData:
	if not pokemon_by_id.has(id):
		print("PokemonData introuvable pour id = %d" % id)
		return null
	return pokemon_by_id[id]
	
func get_item_data(id : String) -> Item_data :
	if not items_by_id.has(id) :
		push_error("item data introuvables")
		return null
	return items_by_id[id]
	
func _load_all_items():
	var dir = DirAccess.open("res://src/ressources/Items/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var item = load("res://src/ressources/Items/" + file_name)
				print(item)
				items_by_id[item.Item_name] = item
				file_name = dir.get_next()
				
func _load_all_pokemon():
	var dir := DirAccess.open("res://src/ressources/PokemonData/")
	if dir == null:
		push_error("Pokedex: dossier introuvable")
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(".tres"):
			var data: PokemonData = load("res://src/ressources/PokemonData/" + file_name)
			pokemon_by_id[data.pokemon_id] = data
		file_name = dir.get_next()
	
	dir.list_dir_end()

	
func has_property(node: Object, property_name: String) -> bool:
	if not node : 
		return false
	for prop in node.get_property_list():
		if prop.name == property_name:
			return true
	return false

func start_transition():
	var fadeAnim = GlobalUI.get_node("TransitionFade")
	fadeAnim.fade_in()
	await fadeAnim.fade_finished

func stop_transition():
	var fadeAnim = GlobalUI.get_node("TransitionFade")
	fadeAnim.fade_out()
	await fadeAnim.fade_finished
	
func startBattleUi():
	battle_ui = battleui.instantiate()
	print(battle_ui)
	get_tree().root.add_child(battle_ui)

func startBattleManager():
	battleManager = Battlemanager.new()
	print(battleManager)
	
func start_wild_battle():
	startBattleManager()
	var p_pokemon = playerManager.player_instance.pokemonTeam
	var random_encounter = PokemonInstance.new()
	var actual_encounter_zone = playerManager.current_zone
	var actual_encounter_zone_level_range = actual_encounter_zone.get_zone_level_range()
	
	random_encounter.data = get_pokemon_data(actual_encounter_zone.get_random_encounters("grass"))
	random_encounter.level = 8 #randi_range(actual_encounter_zone_level_range.x, actual_encounter_zone_level_range.y)
	random_encounter.is_wild = true
	random_encounter.initStats()
	#random_encounter.learnMove(11, 3)
	random_encounter.learnMove(1, 3)
	#random_encounter.learnMove(11, 3)
	#random_encounter.learnMove(12, 3)
	var enemy_team_typed : Array[PokemonInstance] = [random_encounter]
	startBattleUi()
	SoundManager.play_music(preload("res://sound/musics/combat/wild_battle.mp3"), false)
	battleManager.start_battle(p_pokemon, enemy_team_typed)
	var result = await battleManager.battle_ended
	if result :
		print("combat gagné")
	else :
		#gere la posibilité que le joueur n'a plus de pokemon valide ( tp centre pokemon)
		print("combat perdu")
	playerManager.player_instance.Snap_to_grid()

func start_Trainer_battle(TrainerTeam : Array[PokemonInstance], Trainer : CharacterBody2D):
	print("start player battle never called ? ")
	var player_position = Vector2i(playerManager.player_instance.global_position / 16)
	var p_pokemon = playerManager.player_instance.pokemonTeam
	startBattleManager()
	startBattleUi()
	SoundManager.play_music(preload("res://sound/musics/combat/trainer_battle.mp3"), false)
	battleManager.start_battle(p_pokemon, TrainerTeam, Trainer)
	var result = await battleManager.battle_ended
	print("result of the fight : ", result)
	if result : 
		Trainer.trainer_defeted = true
		playerManager.teleport_to(player_position)
	else : 
		print("combat perdu")
	playerManager.player_instance.Snap_to_grid()
	
func get_battleUi() -> CanvasLayer :
	return battle_ui
	
func get_NPC(npc_id : String) -> CharacterBody2D :
	var actual_NPC_in_tree = get_tree().get_nodes_in_group("pnj")
	for Npc in actual_NPC_in_tree :
		if Npc.NPC_id == npc_id :
			return Npc
	return null
	
func change_scene_with_player(closed_node: Node, open_node: String, destination_pos: Vector2):
	if processing_scene_change == true :
		return
	processing_scene_change = true
	await playerManager.desacPlayer(true)
	
	await start_transition()
	
	var new_scene_instance = World_Map.get_scene_in_memory(open_node)

	playerManager.player_instance.reparent(new_scene_instance.get_node("ysortingnode"))
	
	# 4. Retirer et libérer l'ancienne scène
	get_tree().current_scene.remove_child(closed_node)
	
	get_tree().current_scene.add_child(new_scene_instance)
	if not new_scene_instance.is_node_ready():
			await new_scene_instance.ready
	
	current_node = new_scene_instance
	
	await get_tree().process_frame
	
	playerManager.teleport_to(destination_pos)

	
	await stop_transition()
	await get_tree().create_timer(0.2).timeout
	await playerManager.activatePlayer()
	processing_scene_change = false
	print("Changement de scène terminé vers : ", open_node)
