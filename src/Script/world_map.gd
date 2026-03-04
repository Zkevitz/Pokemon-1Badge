extends Node2D
class_name WorldMap

var scene_memory : Dictionary = {
	"MainWorld" : "",
	"FirstForest" : preload("res://src/node/level_node/first_forest.tscn"),
	"ProfShenHouseInterior" : preload("res://src/node/building_interior/profShenHouse.tscn"),
	"SimpleHouse1" : preload("res://src/node/building_interior/house_interior.tscn")
}
var is_launched := false

func _ready() -> void:
	Game.World_Map = self
	playerManager.World_Map = self
	scene_memory["MainWorld"] = get_node("MainWorld")
	#if not StoryManager.get_flag("intro_done"):
		#call_deferred("start_first_event")
	#if is_launched == false :
		#is_launched = true
		#start_first_event()

var g_astar

func start_first_event():
	playerManager.desacPlayer(true)
	var npc = Game.get_NPC("VillageKeeper")
	var base_pos = npc.global_position
	
	await _npc_walk_to_player(npc)
	npc.move_direction = Vector2.LEFT
	npc.animator.play("idle")
	await npc.show_exclamation_mark()
	await _play_dialogue("Gate Keeper")
	_npc_teleport_to(npc, base_pos)
	
	StoryManager.set_flag("intro_done")
	playerManager.activatePlayer()


func _npc_walk_to_player(npc) -> void:
	var npc_map_pos = npc.Walkinggrid.local_to_map(npc.global_position)
	var player_map_pos =  npc.Walkinggrid.local_to_map(playerManager.player_instance.global_position)
	g_astar = npc._setup_AStarGrid(npc_map_pos, 40)
	await npc.follow_AStar_point(g_astar.get_id_path(npc_map_pos, player_map_pos), 1)


func _play_dialogue(dialogue_id: String) -> void:
	DialogueManager.startDialogue(dialogue_id)
	await DialogueManager.dialogue_ended


func _npc_teleport_to(npc, pos: Vector2) -> void:
	npc.visible = false
	npc.global_position = pos
	npc.visible = true


func _exit_tree() -> void:
	# Nettoyer toutes les scènes en mémoire
	for scene in scene_memory:
		if is_instance_valid(scene):
			scene.queue_free()
	scene_memory.clear()
	print("Mémoire des scènes nettoyée")
	
func get_scene_in_memory(Scene_id : String ) -> Node2D:
	var SceneNode = scene_memory[Scene_id]
	var SceneInstance
	if SceneNode is Node2D :
		SceneInstance = SceneNode
	else : 
		SceneInstance = SceneNode.instantiate()
		scene_memory[Scene_id] = SceneInstance
	return SceneInstance
