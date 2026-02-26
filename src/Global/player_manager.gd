extends Node
class_name PlayerManager
var player_instance : CharacterBody2D = null

var World_Map : WorldMap
var current_zone : GameZone
var is_active : bool = true 

func _ready():
	pass
		
func desacPlayer(visible : bool = false):
	is_active = false
	player_instance.update_animation("idle")
	player_instance.visible = visible
	player_instance.currentState = player_instance.animState.IDLE
	player_instance.set_physics_process(false)
	player_instance.set_process(false)
	player_instance.set_process_input(false)
	player_instance.velocity = Vector2.ZERO
	player_instance.target_position = Vector2.ZERO
	player_instance.EnableInput = false
	await get_tree().process_frame
	
	for child in player_instance.get_children() :
		if child is CollisionShape2D :
			child.disabled = true
	
func teleport_to(pos : Vector2):
	var SnappingLayer = get_tree().get_first_node_in_group("walkgrid")
	
	player_instance.global_position = SnappingLayer.map_to_local(pos)

func HealingCenterTp():
	var healingCenterNode = Game.World_Map.get_scene_in_memory(player_instance.LastHealCenterNodeName)
	if healingCenterNode != Game.current_node :
		await Game.change_scene_with_player(Game.current_node, player_instance.LastHealCenterNodeName, player_instance.LastHealCenterPos)
	else : 
		await Game.start_transition()
		teleport_to(player_instance.LastHealCenterPos)
		player_instance.current_direction = Vector2.UP
		await activatePlayer()
		await Game.stop_transition()
	DialogueManager.startDialogue("Vos Pokemon sont desormais soigné !")
	await DialogueManager.dialogue_ended
		
func lock_player():
	is_active = false
	player_instance.EnableInput	= false
	player_instance.currentState = player_instance.animState.IDLE
	player_instance.target_position = Vector2.ZERO
	player_instance.update_animation("idle")
	await get_tree().process_frame

func unlock_player():
	is_active = true
	player_instance.EnableInput = true
	await get_tree().process_frame
	
func activatePlayer():
	is_active = true
	player_instance.visible = true
	await get_tree().create_timer(1).timeout
	for child in player_instance.get_children() :
		if child is CollisionShape2D :
			child.disabled = false
	
	player_instance.set_physics_process(true)
	player_instance.set_process(true)
	player_instance.set_process_input(true)
	player_instance.EnableInput = true
	
func get_player() -> CharacterBody2D :
	return player_instance

func Is_active() -> bool :
	return is_active
#func toggle_physics(node : Variant) -> void :
	##print("toggled physics of node : ", node)
	#if node is Area2D :
		#node.monitoring = not node.monitoring
	#elif node is CollisionShape2D and not node.get_parent().is_in_group("player"):
		#node.disabled = not node.disabled
	#elif node is CharacterBody2D and not node.is_in_group("player") :
		#if node.is_processing():
			#node.set_process(false)
		#else:
			#if node.hasToMove == true :
				#node.set_process(true)
		#if node.is_physics_processing():
			#node.set_physics_process(false)
		#else:
			#if node.hasToMove == true :
				#node.set_physics_process(true)
		#node.collision_layer = 0 if node.collision_layer == 1 else 1
	#elif node is TileMapLayer :
		#node.collision_enabled = false if node.collision_enabled == true else true
		#
#func toggleScene(node : Node2D) -> void :
	#if not node :
		#print("not node is : ", node)
		#return
	#if node.is_in_group("player"):
		#return
	#for child in node.get_children() :
		#toggle_physics(child)
		#if child.get_child_count() > 0 :
			#if child is Node2D:
				#toggleScene(child)
	
