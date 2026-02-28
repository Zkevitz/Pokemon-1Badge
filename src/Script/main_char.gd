extends CharacterBody2D


signal movement_finished

enum animState {IDLE, MOVING}


var SPEED := 70.0
var currentState = animState.IDLE
var current_direction := Vector2.DOWN	
var previous_pos : Vector2
var target_position := Vector2.ZERO
var start_position := Vector2(3, -5)
var EnableInput := true

var pokemonTeam : Array[PokemonInstance]
var player_inventory : Inventory

var LastHealCenterPos : Vector2 = Vector2(1, -7)
var LastHealCenterNodeName : String = "MainWorld"

var is_jumping: bool = false
var current_border: BorderJump = null

#const WALK_FRAMES := 4
var move_progress := 0.0
var move_start_pos := Vector2.ZERO

@onready var walkgrid := get_tree().get_first_node_in_group("walkgrid")
@onready var anim := $Sprite2D
@onready var animation_player := $AnimationPlayer
@onready var collision := $CollisionShape2D

const TURN_TIME := 0.08
var turnTimer := 0.0

var radius := 10
func _draw():
	if walkgrid == null:
		return
	var player_cell: Vector2i = walkgrid.local_to_map(
		global_position
	)
	
	# 2️⃣ parcourir les 10 cases autour
	for x in range(player_cell.x - radius, player_cell.x + radius + 1):
		for y in range(player_cell.y - radius, player_cell.y + radius + 1):
			
			var cell = Vector2i(x, y)
			
			# 3️⃣ cellule → position locale propre
			var cell_local_pos = walkgrid.map_to_local(cell)
			
			draw_rect(
				Rect2(cell_local_pos, walkgrid.tile_set.tile_size),
				Color(0, 1, 0, 0.2),
				false,
				1.0
			)
func _ready() -> void:
	global_position = walkgrid.map_to_local(start_position)
	previous_pos = start_position
	player_inventory = Inventory.new()
	player_inventory.add_item(Game.get_item_data("Potion"))
	player_inventory.add_item(Game.get_item_data("Potion"))
	player_inventory.add_item(Game.get_item_data("Super Potion"))
	player_inventory.add_item(Game.get_item_data("SuperBall"))
	player_inventory.add_item(Game.get_item_data("PokeBall"))
	var pokemon = PokemonInstance.new()
	var pokemon2 = PokemonInstance.new()
	pokemon.data = Game.get_pokemon_data(14)
	pokemon2.data = Game.get_pokemon_data(4)
	pokemon2.level = 8
	pokemon2.initStats()
	pokemon.level = 5
	pokemon.initStats()
	pokemon.learnMove(10, 3)
	pokemon.learnMove(16, 3)
	pokemon.learnMove(3, 3)
	pokemon.learnMove(18, 3)
	pokemon.current_xp = 90
	pokemonTeam.append(pokemon)
	pokemonTeam.append(pokemon2)
	
	playerManager.player_instance = self
	queue_redraw()
	
func _physics_process(delta: float) -> void:
	#DEBUG
	#var tileposition = walkgrid.map_to_local(global_position) / 16
	#print("tileposition :", tileposition)
	if is_jumping : 
		return
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
			return
		if Input.is_action_pressed("combined") :
			SPEED = 100
		else :
			SPEED = 70
		attempt_move(input_direction)
	else :
		update_animation("idle")
		
func Snap_to_grid():
	var tilePosition = walkgrid.local_to_map(global_position)
	global_position = walkgrid.map_to_local(tilePosition)
	
func cancel_last_move():
	global_position = previous_pos
	Snap_to_grid()
	
func receiveGift(recompenseType : Game.recompenseType, recompense_id : int = 0, pokemon_level : int = 5): 
	if recompenseType == Game.recompenseType.POKEMON :
		var newPokemon = PokemonInstance.new()
		newPokemon.data = Game.get_pokemon_data(recompense_id)
		newPokemon.level = pokemon_level
		newPokemon.initStats()
		add_pokemon_in_team(newPokemon)
	elif recompenseType == Game.recompenseType.TEAM_HEALING : 
		full_heal_team()
	else: 
		print("object receive a implementer")

func full_heal_team():
	for poke in pokemonTeam :
		poke.CenterHealing()	
		
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

func handle_moving_state(delta : float):
	if EnableInput == false :
		target_position = Vector2.ZERO
		return
	position = position.move_toward(target_position, SPEED * delta)
	
	if position.distance_to(target_position) < 1.0 :
		position = target_position
		currentState = animState.IDLE
		emit_signal("movement_finished")
		var input_direction := get_input_direction()
		if input_direction != Vector2.ZERO:
			attempt_move(input_direction)

func attempt_move(direction : Vector2) :
	var collisiontest := move_and_collide(direction * Game.tileSize, true, 0.08, true)
		
	if not collisiontest :
		current_direction = direction
		previous_pos = global_position
		target_position = position + direction * Game.tileSize
		if SPEED == 70 :
			update_animation("Walking")
		elif SPEED == 100 :
			update_animation("Run")
		currentState = animState.MOVING
	else :
		current_direction = direction
		if collisiontest.get_collider().is_in_group("Border") :
			attempt_border_jump(collisiontest.get_collider())
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
	
	var anim_name = prefix + type
	if prefix:
		anim.animation = anim_name
	if type != "idle" :
		animation_player.play(type)
		
func attempt_border_jump(border : BorderJump):
	if is_jumping:
		return
	current_border = border
	if border.can_player_pass(current_direction) :
		print("perform jump!")
		perform_jump(border)
	
func perform_jump(border: BorderJump):
	is_jumping = true
	
	var jump_offset = border.get_jump_offset()
	var target_pos = global_position + jump_offset
	print("performing jump global_position : ", global_position)
	print("performing jump target_position : ", target_pos)
	
	var tween = create_tween()
	#tween.set_parallel(true)
	
	tween.tween_property(self, "global_position", target_pos, border.jump_duration)
	
	var jump_tween = create_tween()
	jump_tween.tween_property(
		$Sprite2D,
		"position:y",
		-border.jump_height,
		border.jump_duration / 2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	jump_tween.tween_property(
		$Sprite2D,
		"position:y",
		-7.0,
		border.jump_duration / 2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	SoundManager.play_sfx(preload("res://sound/SFX/Divers/Player jump.ogg"), -10)
	
	await tween.finished
	is_jumping = false
	current_border = null
		

func play_foot_step():
	SoundManager.play_foot_step(global_position)

func update_direction_to(pos : Vector2) :
	previous_pos = global_position - (current_direction * Game.tileSize)
	var motion = pos - global_position
	var dir = motion.normalized()
	current_direction = dir.sign()
