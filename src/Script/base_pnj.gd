extends CharacterBody2D


const SPEED := 30.0
const tilesize := Game.tileSize
const timeBetweenMove := 3.0

enum animState {IDLE, MOVING, NONE, MOVE_TO_PLAYER}

signal movement_ended
var directions = [
		Vector2.LEFT,
		Vector2.RIGHT,
		Vector2.UP,
		Vector2.DOWN
	]

@export var NPC_id : String = ""
@export var spriteframe : SpriteFrames
@export var hasToMove : bool = true
@export var hasPathfollow : bool = false
@export var is_trainer : bool = false
@export var has_to_be_interactive : bool = true
@export var has_raycast : bool = false
@export var hasDialogue : bool = true

@export var Walkinggrid : TileMapLayer
@export var MovingArea : Area2D
@export var startDirection : Vector2 = Vector2.DOWN
@export var pokemonteamdata : Array[TrainerPokemonData]
@export var MovingrangeSize : Vector2 = Vector2(128, 96)
@export var StartPosition : Vector2 = Vector2(5, -4)

@onready var anim := $Sprite2D
@onready var interactRange := $interactRange
@onready var raycast := get_node("RayCast2D") if has_raycast else null
@onready var MovingAreaCollision : RectangleShape2D
@onready var exclamation_sprite := $Marker2D/Sprite2D
@onready var exclamation_anim := $Marker2D/AnimationPlayer

var pokemonTeam : Array[PokemonInstance]
var mouvement_timer := 0.0
var currentState = animState.IDLE
var move_direction := Vector2.ZERO
var last_direction := Vector2.RIGHT
var target_position : Vector2
var AreaSize : Rect2
var player_detected := false
var trainer_defeted := false

func _ready():
	exclamation_sprite.visible = false
	print("start direction : ", startDirection)
	move_direction = startDirection
	update_animation("idle")
	global_position = Walkinggrid.map_to_local(StartPosition)
	if spriteframe :
		anim.sprite_frames = spriteframe
	if hasToMove == false :
		set_physics_process(false)
	else :
		if hasPathfollow == false :
			MovingAreaCollision = MovingArea.get_node("CollisionShape2D").shape
			target_position = global_position
			mouvement_timer = timeBetweenMove
			AreaSize = MovingAreaCollision.get_rect()
			
	if has_to_be_interactive == false : 
		interactRange.monitoring = false
	print("is trainer : ", is_trainer)
	if is_trainer :
		load_pokemon_team(pokemonteamdata)
	
func _physics_process(delta: float) -> void:
	match currentState:
		animState.IDLE:
			handle_idle(delta)
		animState.MOVING:
			handle_moving(delta)
		animState.MOVE_TO_PLAYER :
			handle_moving(delta)

func load_pokemon_team(pokemonTeamdata : Array[TrainerPokemonData]):
	for i in range(pokemonTeamdata.size()) :
		var pokemonid = pokemonTeamdata[i].PokemonIds
		var tmp_poke = PokemonInstance.new()
		tmp_poke.data = Game.get_pokemon_data(pokemonid) 
		tmp_poke.level = pokemonTeamdata[i].PokemonLevel
		tmp_poke.is_wild = true
		tmp_poke.initStats(pokemonTeamdata[i].PokemonMoves)
		print("trainer pokemon move : ", tmp_poke.moves)
		print("pokemon added to trainer team : ", tmp_poke)
		pokemonTeam.append(tmp_poke)
		
		
func get_position_in_front_of_player() -> Vector2:
	var player = playerManager.player_instance
	return player.global_position - (-player.current_direction) * Game.tileSize

var g_astar 

#DEBUG
func _draw():
	if g_astar == null:
		return
	
	var region = g_astar.region
	
	for x in range(region.position.x, region.end.x):
		for y in range(region.position.y, region.end.y):
			
			var world_pos = Vector2(x, y) * tilesize
			var local_pos = world_pos - global_position
			
			draw_rect(
				Rect2(local_pos, Vector2(tilesize, tilesize)),
				Color(0, 1, 0, 0.2), # vert transparent
				false, # outline seulement
				1.0
			)
			
func _setup_AStarGrid(center : Vector2i, radius : int):
	var astar := AStarGrid2D.new()
	astar.region = Rect2i(center - Vector2i(radius, radius),
							 Vector2i(radius * 2 + 1, radius * 2 + 1))
							
	astar.cell_size = Vector2(tilesize, tilesize)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()
	return astar

func block_player_way(event : int ):
	raycast.enabled = false
	playerManager.player_instance.update_direction_to(global_position)
	await playerManager.desacPlayer(true)
	await show_exclamation_mark()
	
	
	var npc_map_pos =  Walkinggrid.local_to_map(global_position)
	var return_pos = npc_map_pos
	var player_map_pos =  Walkinggrid.local_to_map(playerManager.player_instance.global_position)
	g_astar = _setup_AStarGrid(npc_map_pos, 10)
	var Point_in_path = g_astar.get_id_path(npc_map_pos, player_map_pos)
	queue_redraw()
	await follow_AStar_point(Point_in_path, 1)

	interactRange.monitoring = true
	interactRange.player_nearby = true
	if hasDialogue == true :
		DialogueManager.startDialogue(interactRange.dialogue_id)
		await DialogueManager.dialogue_ended
		interactRange.player_nearby = false
		interactRange.monitoring = false
	
	if event == 0 : # COMPORTEMENT 1 reviens a sa place apres le dialogue
		Point_in_path = g_astar.get_id_path(Walkinggrid.local_to_map(global_position), return_pos)
		
		await follow_AStar_point(Point_in_path)
		move_direction = startDirection
		update_animation("idle")
		playerManager.player_instance.cancel_last_move()
		await playerManager.activatePlayer()
		interactRange.monitoring = false
		interactRange.player_nearby = false
		raycast.enabled = true
	
	elif event == 1 : #COMPORTEMENT 2 lance un combat 
		await Game.start_Trainer_battle(pokemonTeam, self)
		if trainer_defeted == true : 
			remove_child(raycast)
		else : 
			global_position = Walkinggrid.map_to_local(return_pos)
		interactRange.monitoring = true
		playerManager.activatePlayer()

			
func show_exclamation_mark():
	print("=== DEBUT show_exclamation_mark ===")
	currentState = animState.NONE
	
	exclamation_sprite.visible = true
	exclamation_sprite.modulate.a = 1.0
	exclamation_anim.play("exclamationMark")
	SoundManager.play_sfx(preload("res://sound/SFX/Exclaim.ogg"), -20)
	
	await exclamation_anim.animation_finished
	exclamation_sprite.visible = false
			
func go_to(target_pos : Vector2):
	target_position = target_pos
	currentState = animState.MOVING
	set_physics_process(true)
	
	await movement_ended
	currentState = animState.IDLE
	set_physics_process(false)

func follow_AStar_point(astar_point : Array[Vector2i], last_point_execption = 0) :
	print(astar_point)
	for i in range(1, astar_point.size() - last_point_execption):
		var from_point = astar_point[i - 1]
		var to_point = astar_point[i]

		var direction = (to_point - from_point).sign()

		if direction != Vector2i(move_direction):
			move_direction = direction

		await go_to(Walkinggrid.map_to_local(to_point))
	
func handle_idle(delta : float ) :
	mouvement_timer -= delta
	update_animation("idle")
	
	if mouvement_timer <= 0.0 :
		
		var areaGlobalPos = MovingArea.global_position
		var areaRect = Rect2(areaGlobalPos - AreaSize.size / 2.0, AreaSize.size)
		directions.shuffle()
		for dir in directions : 
			var candidate  = global_position + dir * Game.tileSize
			if _is_inside_area(candidate, areaRect) :
				target_position = candidate
				currentState = animState.MOVING
				move_direction = dir
				return
		target_position = global_position

func _is_inside_area(candidate : Vector2, areaRect : Rect2) -> bool :
	var motion = candidate - global_position
	var collision = move_and_collide(motion, true)
	if collision :
		return false
	var isInside = areaRect.has_point(candidate)	
	return isInside

func handle_path_moving(delta : float ) -> bool:
	var motion = target_position - global_position
	
	if motion.length() > SPEED * delta:
		motion = motion.normalized() * SPEED * delta
	
	update_animation("Walking")
	var collision = move_and_collide(motion, true)
	if collision: 
		return true
	
	move_and_collide(motion)
	return false
	
func handle_moving(delta :float) : 
	update_animation("Walking")
	

	global_position = global_position.move_toward(target_position, SPEED * delta)
	
	#print("currentstate ", currentState)
	if global_position.distance_to(target_position) < 0.5 :
		global_position = target_position
		currentState = animState.IDLE
		update_animation("idle")
		mouvement_timer = timeBetweenMove
		emit_signal("movement_ended")
	
func update_animation(type : String)-> void :
	var prefix := ""
	if move_direction == Vector2.UP :
		prefix = "back"
	elif move_direction == Vector2.DOWN :
		prefix = "face"
	elif move_direction == Vector2.LEFT :
		prefix = "left"
	elif move_direction == Vector2.RIGHT :
		prefix = "right"
	
	if prefix:
		var anim_name = prefix + type
		anim.play(anim_name)
