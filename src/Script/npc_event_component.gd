extends Node
class_name NpcEventComponent

var _npc : CharacterBody2D

func setup(npc: CharacterBody2D) -> void:
	_npc = npc
	_npc.get_node("Marker2D/Sprite2D").visible = false


func show_exclamation_mark() -> void:
	_npc.currentState = _npc.animState.NONE
	var sprite = _npc.get_node("Marker2D/Sprite2D")
	var anim = _npc.get_node("Marker2D/AnimationPlayer")
	sprite.visible = true
	sprite.modulate.a = 1.0
	anim.play("exclamationMark")
	SoundManager.play_sfx(preload("res://sound/SFX/Exclaim.ogg"), -20)
	await anim.animation_finished
	sprite.visible = false


func block_player_way(event: int, let_him_pass: bool) -> void:
	playerManager.desacPlayer(true)
	_npc.raycast.enabled = false
	playerManager.player_instance.update_direction_to(_npc.global_position)
	await show_exclamation_mark()
	
	var npc_map_pos    = _npc.Walkinggrid.local_to_map(_npc.global_position)
	var return_pos     = npc_map_pos   
	var player_map_pos = _npc.Walkinggrid.local_to_map(playerManager.player_instance.global_position)
	var astar          = _npc.pathfinder.setup_astar_grid(npc_map_pos, 10)
	var path           = astar.get_id_path(npc_map_pos, player_map_pos)
	await _npc.pathfinder.follow_path(path, 1)
	
	_npc.interact_range.monitoring = true
	_npc.interact_range.player_nearby = true
	if _npc.hasDialogue:
		DialogueManager.startDialogue(_npc.interact_range.dialogue_id)
		await DialogueManager.dialogue_ended
		_npc.interact_range.player_nearby = false
		_npc.interact_range.monitoring = false                   
	match event:
		0: await _return_to_base(return_pos, let_him_pass)
		1: await _start_battle(return_pos)


func _return_to_base(return_pos: Vector2i, let_him_pass: bool) -> void:
	var astar = _npc.pathfinder.setup_astar_grid(
	_npc.Walkinggrid.local_to_map(_npc.global_position), 10)
	var path  = astar.get_id_path(
		_npc.Walkinggrid.local_to_map(_npc.global_position), return_pos)
	await _npc.pathfinder.follow_path(path)
	_npc.move_direction = _npc.start_direction
	_npc.animator.play("idle")
	if not let_him_pass:
		playerManager.player_instance.cancel_last_move()
	await playerManager.activatePlayer()
	_npc.interact_range.monitoring = false
	_npc.interact_range.player_nearby = false
	_npc.raycast.enabled = true


func _start_battle(return_pos: Vector2i) -> void:
	await Game.start_Trainer_battle(_npc.pokemonTeam, _npc)
	if _npc.trainer_defeted:
		_npc.remove_child(_npc.raycast)
	else:
		_npc.global_position = _npc.Walkinggrid.map_to_local(return_pos)
	_npc.interact_range.monitoring = true
	playerManager.activatePlayer()
