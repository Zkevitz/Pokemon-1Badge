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
	#debug
	#print("healing center scene file path :", healingCenterNode.scene_file_path)
	#print("actual scene file path : ", Game.current_node.scene_file_path)
	if healingCenterNode.scene_file_path != Game.current_node.scene_file_path :
		await Game.change_scene_with_player(Game.current_node, player_instance.LastHealCenterNodeName, player_instance.LastHealCenterPos)
	else : 
		await Game.start_transition()
		teleport_to(player_instance.LastHealCenterPos)
		player_instance.current_direction = Vector2.UP
		await activatePlayer()
		await Game.stop_transition()
	DialogueManager.startDialogue("Vos Pokemon sont desormais soigné !")
	player_instance.full_heal_team()
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
