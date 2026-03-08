extends CharacterBody2D

@onready var animator := $NpcAnimationComponent
@onready var movement := $NpcMovementComponent
@onready var pathfinder := $NpcPathfindingComponent
@onready var events := $NpcEventComponent

const tilesize := Game.tileSize

enum animState {IDLE, MOVING, NONE, MOVE_TO_PLAYER}

@export var NPC_id : String = ""
@export var spriteframe : SpriteFrames
@export var has_to_move : bool = true
@export var has_path_follow : bool = false
@export var is_trainer : bool = false
@export var has_to_be_interactive : bool = true
@export var has_raycast : bool = false
@export var hasDialogue : bool = true

@export var Walkinggrid : TileMapLayer
@export var MovingArea : Area2D
@export var start_direction : Vector2 = Vector2.DOWN
@export var pokemon_team_data : Array[TrainerPokemonData]
@export var moving_range_size : Vector2 = Vector2(128, 96)
@export var StartPosition : Vector2 = Vector2(5, -4)

@onready var anim := $NpcSprite
@onready var interact_range := $interactRange
@onready var raycast := get_node("RayCast2D") if has_raycast else null

var pokemonTeam : Array[PokemonInstance]
var currentState = animState.IDLE
var move_direction := Vector2.ZERO
var player_detected := false
var trainer_defeted := false

func _ready():
	_setup_components()
	_setup_position()
	_setup_movement()
	_setup_interact()
	if is_trainer :
		load_pokemon_team(pokemon_team_data)


func _setup_components() -> void:
	animator.setup(self)
	movement.setup(self)
	pathfinder.setup(self)
	events.setup(self)


func _setup_position() -> void:
	global_position = Walkinggrid.map_to_local(StartPosition)
	move_direction = start_direction
	if spriteframe :
		anim.sprite_frames = spriteframe
	animator.play("idle")


func _setup_movement() -> void:
	if not has_to_move:
		set_physics_process(false)
		return
	if not has_path_follow:
		if MovingArea == null:
			return
		var shape = MovingArea.get_node("CollisionShape2D").shape as RectangleShape2D
		movement.AreaSize = shape.get_rect()
		movement.target_position = global_position
		movement.mouvement_timer = movement.TIME_BETWEEN_MOVE


func _setup_interact() -> void:
	if not has_to_be_interactive:
		interact_range.monitoring = false

func _physics_process(delta: float) -> void:
	match currentState:
		animState.IDLE: movement.handle_idle(delta)
		animState.MOVING: movement.handle_moving(delta)
		animState.MOVE_TO_PLAYER : movement.handle_moving(delta)


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

#var g_astar
#DEBUG
#func _draw():
#	if g_astar == null:
#		return
#	var region = g_astar.region
#	for x in range(region.position.x, region.end.x):
#		for y in range(region.position.y, region.end.y):
#			var world_pos = Vector2(x, y) * tilesize
#			var local_pos = world_pos - global_position			
#			draw_rect(
#				Rect2(local_pos, Vector2(tilesize, tilesize)),
#				Color(0, 1, 0, 0.2), # vert transparent
#				false, # outline seulement
#				1.0
#			)


func _setup_AStarGrid(center : Vector2i, radius : int):
	return pathfinder.setup_astar_grid(center, radius)

func block_player_way(event : int, let_him_pass: bool) -> void:
	await events.block_player_way(event, let_him_pass)

			
func show_exclamation_mark() -> void:
	await events.show_exclamation_mark()


func go_to(target_pos : Vector2) -> void:
	await movement.go_to(target_pos)


func follow_AStar_point(astar_point : Array[Vector2i], last_point_execption = 0) :
	await pathfinder.follow_path(astar_point, last_point_execption)


func handle_path_moving(delta : float ) -> bool:
	var motion = movement.target_position - global_position
	if motion.length() > movement.SPEED * delta:
		motion = motion.normalized() * movement.SPEED * delta
	animator.play("Walking")
	var collision = move_and_collide(motion, true)
	if collision: 
		return true
	move_and_collide(motion)
	return false
