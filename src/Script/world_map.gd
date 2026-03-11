extends Node2D
class_name WorldMap

var scene_memory : Dictionary = {
	"MainWorld" : preload("res://src/node/level_node/main_world.tscn"),
	"FirstForest" : preload("res://src/node/level_node/first_forest.tscn"),
	"ProfShenHouseInterior" : preload("res://src/node/building_interior/profShenHouse.tscn"),
	"SimpleHouse1" : preload("res://src/node/building_interior/house_interior.tscn")
}
var is_launched := false

#func _process(_delta: float) -> void:
	#print_orphan_nodes()
func _ready() -> void:
	Game.World_Map = self
	playerManager.World_Map = self
	if not StoryManager.get_flag(StoryManager.Flag.INTRO_DONE):
		#call_deferred("start_first_event")
		StoryManager.set_flag(StoryManager.Flag.INTRO_DONE)
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
	
	StoryManager.set_flag(StoryManager.Flag.INTRO_DONE)
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

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		exit_tree()
		
func exit_tree() -> void:
	# Nettoyer toutes les scènes en mémoire
	print("Mémoire des scènes nettoyée")
	for scene in scene_memory:
		print("scene to see : ", scene_memory[scene])
		if is_instance_valid(scene_memory[scene]) and scene_memory[scene] is Node2D:
			print("free")
			add_child(scene_memory[scene])
			scene_memory[scene].queue_free()
	print_orphan_nodes()
	scene_memory.clear()
	queue_free()
	
func get_scene_in_memory(Scene_id : String ) -> Node2D:
	var SceneNode = scene_memory[Scene_id]

	var SceneInstance = SceneNode.instantiate()
	return SceneInstance
