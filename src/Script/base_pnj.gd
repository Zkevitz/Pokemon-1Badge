extends CharacterBody2D


const SPEED := 100.0
const timeBetweenMove := 3.0

enum animState {IDLE, MOVING, NONE, MOVE_TO_PLAYER}
var directions = [
		Vector2.LEFT,
		Vector2.RIGHT,
		Vector2.UP,
		Vector2.DOWN
	]

@export var spriteframe : SpriteFrames
@export var hasToMove : bool = true
@export var hasPathfollow : bool = false
@export var StartPosition : Vector2 = Vector2(5, -4)
@export var MovingrangeSize : Vector2 = Vector2(128, 96)
@export var has_raycast : bool = false
@export var Walkinggrid : TileMapLayer
@export var MovingArea : Area2D
@export var hasDialogue : bool = true
@export var has_to_be_interactive : bool = true
@export var startDirection : Vector2 = Vector2.DOWN

@onready var anim := $Sprite2D
@onready var interactRange := $interactRange
@onready var raycast := $RayCast2D
@onready var MovingAreaCollision : RectangleShape2D
@onready var exclamation_sprite := $Marker2D/Sprite2D
@onready var exclamation_anim := $Marker2D/AnimationPlayer

var mouvement_timer := 0.0
var return_pos := Vector2.ZERO
var currentState = animState.IDLE
var move_direction := Vector2.ZERO
var last_direction := Vector2.RIGHT
var target_position : Vector2
var AreaSize : Rect2
var player_detected := false

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
		else :
			currentState = animState.MOVING
			
	if has_raycast == false : 
		remove_child(raycast)
	if has_to_be_interactive == false : 
		interactRange.monitoring = false
	
func _physics_process(delta: float) -> void:
	match currentState:
		animState.IDLE:
			handle_idle(delta)
		animState.MOVING:
			handle_moving(delta)
		animState.MOVE_TO_PLAYER :
			handle_moving(delta)

	
func get_position_in_front_of_player() -> Vector2:
	var player = playerManager.player_instance
	return player.global_position - (-player.current_direction) * Game.tileSize

	
func show_exclamation_mark():
	print("=== DEBUT show_exclamation_mark ===")
	playerManager.desacPlayer(true)
	currentState = animState.NONE
	
	# Animation du point d'exclamation
	exclamation_sprite.visible = true
	exclamation_sprite.modulate.a = 1.0
	exclamation_anim.play("exclamationMark")
  	
	return_pos = global_position
	target_position = get_position_in_front_of_player()
	
	await exclamation_anim.animation_finished
	
	# Déplacement vers le joueur
	currentState = animState.MOVE_TO_PLAYER
	set_physics_process(true)
	exclamation_sprite.visible = false
	interactRange.monitoring = true
	
	# Attendre d'être en position
	while currentState == animState.MOVE_TO_PLAYER:
		await get_tree().process_frame
	
	# Maintenant en position, lancer le dialogue
	if hasDialogue == true : 
		DialogueManager.startDialogue(interactRange.dialogue_id)
		await DialogueManager.dialogue_ended
	
	# Retour à la position initiale
	target_position = return_pos
	currentState = animState.MOVE_TO_PLAYER
	set_physics_process(true)
	
	# Attendre le retour
	while currentState == animState.MOVE_TO_PLAYER:
		await get_tree().process_frame
	
	# Nettoyage final (TOUJOURS exécuté)
	playerManager.player_instance.cancel_last_move()
	interactRange.monitoring = false
	interactRange.player_nearby = false
	playerManager.activatePlayer()
	
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
				print("is inside area true : animstate is on moving")
				target_position = candidate
				currentState = animState.MOVING
				move_direction = dir
				return
		target_position = global_position

func _is_inside_area(candidate : Vector2, areaRect : Rect2) -> bool :
	var motion = candidate - global_position
	var collision = move_and_collide(motion, true)
	if collision :
		print("pnj get collision mouvement cancelled")
		return false
	var isInside = areaRect.has_point(candidate)	
	return isInside

func handle_path_moving(delta : float ) -> bool:
	var motion = target_position - global_position
	
	#print("motion = :", motion)
	#if motion.length() < 0.1:
		#move_direction = last_direction
	#else :
		#var dir = motion.normalized()
		#last_direction = dir 
		#move_direction = dir
	
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
		if currentState == animState.MOVE_TO_PLAYER :
			print("currentstate : ", currentState)
			interactRange.player_nearby = true
			set_physics_process(false)
		global_position = target_position
		currentState = animState.IDLE
		update_animation("idle")
		mouvement_timer = timeBetweenMove
	
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
