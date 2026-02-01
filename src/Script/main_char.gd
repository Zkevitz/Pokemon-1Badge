extends CharacterBody2D


@export var SPEED := 100.0

enum animState {IDLE, MOVING}

var currentState = animState.IDLE
var current_direction := Vector2.DOWN	
var target_position := Vector2.ZERO
var start_position := Vector2(12, 0)
var EnableInput := true
var pokemonTeam : Array[PokemonInstance]

@onready var walkgrid := $"../../floor"
@onready var anim := $Sprite2D
@onready var collision := $CollisionShape2D

const TURN_TIME := 0.12
var turnTimer := 0.0

func _ready() -> void:
	playerManager.player_instance = self
	global_position = walkgrid.map_to_local(start_position)
	var pokemon = PokemonInstance.new()
	pokemon.data = Game.get_data(2)
	pokemon.level = 10
	pokemon.initStats()
	pokemon.learnMove(8, 3)
	pokemon.learnMove(10, 3)
	pokemon.current_xp = 90
	pokemonTeam.append(pokemon)
	pass
	
func _physics_process(delta: float) -> void:
	var tileposition = walkgrid.map_to_local(global_position) / 16
	#print("tileposition :", tileposition)
	match currentState :
		animState.IDLE :
			handle_idle_state(delta)
		animState.MOVING:
			handle_moving_state(delta)

func handle_idle_state( _delta : float ) -> void:
	var input_direction := get_input_direction()
	
	if turnTimer > 0:
		turnTimer -= _delta
		update_animation("idle")
		return
	if input_direction != Vector2.ZERO :
		if input_direction != current_direction:
			current_direction = input_direction
			update_animation("idle")
			turnTimer = TURN_TIME
		else:
			attempt_move(input_direction)
	else :
		update_animation("idle")
		
func Snap_to_grid():
	var tilePosition = walkgrid.map_to_local(global_position)
	tilePosition.y -= 1
	walkgrid.map_to_local(tilePosition)
	
func cancel_last_move():
	var backDirection = -current_direction
	
	target_position = position + backDirection * Game.tileSize
	position = position.move_toward(target_position, SPEED)
	
func receiveGift(recompenseType : Game.recompenseType, recompense_id : int = 0, pokemon_level : int = 5): 
	if recompenseType == Game.recompenseType.POKEMON :
		var newPokemon = PokemonInstance.new()
		newPokemon.data = Game.get_data(recompense_id)
		newPokemon.level = pokemon_level
		newPokemon.initStats()
		add_pokemon_in_team(newPokemon)
	elif recompenseType == Game.recompenseType.TEAM_HEALING : 
		for poke : PokemonInstance in pokemonTeam :
			poke.CenterHealing()
	else: 
		print("object receive a implementer")
		
func add_pokemon_in_team(newPokemon : PokemonInstance):
	pokemonTeam.append(newPokemon)
	
func get_input_direction() -> Vector2 :
	if EnableInput == false :
		target_position = Vector2.ZERO
		return Vector2.ZERO
	if Input.is_action_pressed("forward") :
		return Vector2.UP
	elif Input.is_action_pressed("backward") :
		return Vector2.DOWN
	elif Input.is_action_pressed("left"):
		return Vector2.LEFT
	elif Input.is_action_pressed("right"):
		return Vector2.RIGHT
	else :
		return Vector2.ZERO
	var input_direction := get_input_direction()
	
	if input_direction != Vector2.ZERO :
		attempt_move(input_direction)
	else :
		update_animation("idle")
		
func handle_moving_state(delta : float):
	if EnableInput == false :
		target_position = Vector2.ZERO
		return
	position = position.move_toward(target_position, SPEED * delta)
	
	if position.distance_to(target_position) < 1.0 :
		position = target_position
		currentState = animState.IDLE
		var input_direction := get_input_direction()
		if input_direction != Vector2.ZERO:
			attempt_move(input_direction)

func attempt_move(direction : Vector2) :
	var collisiontest := move_and_collide(direction * Game.tileSize, true, 0.08, true)
		
	if not collisiontest :
		current_direction = direction
		target_position = position + direction * Game.tileSize
		update_animation("Walking")
		currentState = animState.MOVING
	else :
		current_direction = direction
		update_animation("idle")
		print("collision avec : ", collisiontest.get_collider().name)
		
func update_animation(type : String)-> void :
	var prefix := ""
	if current_direction == Vector2.UP :
		prefix = "back"
	elif current_direction == Vector2.DOWN :
		prefix = "face"
	elif current_direction == Vector2.LEFT :
		prefix = "left"
	elif current_direction == Vector2.RIGHT :
		prefix = "right"
	
	if prefix:
		var anim_name = prefix + type
		anim.play(anim_name)
