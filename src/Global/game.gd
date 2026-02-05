extends Node

const tileSize := 16
var tile_center_offset = Vector2.ONE * tileSize * 0.5
var returnPosition := Vector2.ZERO
var returnScene : Node2D
var actualNode : Node2D
var toggle_timer := 2.0
var pokemon_by_id: Dictionary = {}
var move_cache := {}
var GlobalUI
var battleManager : Battlemanager
var battleui = preload("res://src/node/battle_ui.tscn")
var battle_ui

enum recompenseType {POKEMON, OBJECT, TEAM_HEALING}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_load_all_pokemon()

func get_move_data(id: int) -> CT_data:
	if not move_cache.has(id):
		var path := "res://src/ressources/CTdata/%d.tres" % id
		move_cache[id] = load(path)
	return move_cache[id]
		
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

func get_data(id: int) -> PokemonData:
	if not pokemon_by_id.has(id):
		print("PokemonData introuvable pour id = %d" % id)
		return null
	print("apparement on a les données ?")
	return pokemon_by_id[id]
	
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
	
func toggleWorld(NodetoShow : Node2D, NodetoHide : Node2D):
	#CA CASSE TOUT ??? 
	#await fadeAnim.fade_finished
	
	playerManager.desacPlayer()
	start_transition()
	
	playerManager.toggleScene(NodetoHide)
	NodetoHide.visible = false
	
	playerManager.toggleScene(NodetoShow)
	NodetoShow.visible = true
	
	playerManager.player_instance.reparent(NodetoShow.get_node("ysortingnode"))
	
	if Game.returnPosition != Vector2.ZERO :
		playerManager.teleport_to(NodetoShow, Game.returnPosition)
		Game.returnPosition = Vector2.ZERO
	elif NodetoShow.SpawnPosition != Vector2.ZERO :
		Game.returnPosition = Vector2i(playerManager.player_instance.global_position / 16)
		playerManager.teleport_to(NodetoShow, NodetoShow.SpawnPosition)
		
	await get_tree().process_frame
	stop_transition()
	playerManager.activatePlayer()
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
	print(p_pokemon)
	var random_encounter = PokemonInstance.new()
	random_encounter.data = get_data(1)
	print("data from pokedex :", random_encounter.data)
	random_encounter.level = (randi() % 5) + 1
	random_encounter.is_wild = true
	random_encounter.initStats()
	print(random_encounter)
	var enemy_team_typed : Array[PokemonInstance] = [random_encounter]
	#start_transition()
	startBattleUi()
	battleManager.start_battle(p_pokemon, enemy_team_typed)
	var result = await battleManager.battle_ended
	if result :
		print("combat gagné")
	else :
		#gere la posibilité que le joueur n'a plus de pokemon valide ( tp centre pokemon)
		print("combat perdu")
	playerManager.player_instance.Snap_to_grid()

func start_Trainer_battle(TrainerTeam : Array[PokemonInstance], Trainer : CharacterBody2D):
	var player_position = Vector2i(playerManager.player_instance.global_position / 16)
	var p_pokemon = playerManager.player_instance.pokemonTeam
	startBattleUi()
	startBattleManager()
	battleManager.start_battle(p_pokemon, TrainerTeam, Trainer)
	var result = await battleManager.battle_ended
	print("result of the fight : ", result)
	if result : 
		Trainer.trainer_defeted = true
		playerManager.teleport_to(playerManager.player_instance.get_parent().get_parent(), player_position)
	else : 
		print("combat perdu")
	playerManager.player_instance.Snap_to_grid()
	
func get_battleUi() -> CanvasLayer :
	return battle_ui
	

func change_scene_with_player(destination_scene_path : PackedScene, destination_pos : Vector2):
	print("===== AVANT CHANGEMENT =====")
	print("Scène actuelle: ", get_tree().current_scene.name)
	print("Toutes les portes: ", get_tree().get_nodes_in_group("doors"))
	
	var current_scene = get_tree().current_scene
	#retiré au mauvais node 
	current_scene.remove_child(playerManager.player_instance)
	current_scene.remove_child(GlobalUI)

	
	get_tree().change_scene_to_packed(destination_scene_path)
	await get_tree().scene_changed
	
	print("===== APRÈS CHANGEMENT =====")
	print("Nouvelle scène: ", get_tree().current_scene.name)
	await get_tree().process_frame  # IMPORTANT : attendez 1 frame
	print("Toutes les portes: ", get_tree().get_nodes_in_group("doors"))
	
	var new_scene = get_tree().current_scene
	new_scene.add_child(GlobalUI)
	
	var ysortingnode = new_scene.get_node("ysortingnode")
	ysortingnode.add_child(playerManager.player_instance)
	
	playerManager.teleport_to(get_tree().get_first_node_in_group("walkgrid").get_parent(), destination_pos)
