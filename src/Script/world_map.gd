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
	#if is_launched == false :
		#is_launched = true
		#start_first_event()

func start_first_event():
	playerManager.desacPlayer(true)
	var village_keeper_npc = Game.get_NPC("VillageKeeper")
	village_keeper_npc.go_to(village_keeper_npc.get_position_in_front_of_player())
	
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
