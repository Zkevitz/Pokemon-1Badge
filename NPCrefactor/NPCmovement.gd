extends Node
class_name NPCMovement

signal movement_started(direction : Vector2)
signal movement_completed
signal direction_changed(new_direction : Vector2)

const SPEED := 60.0
const TileSize := Game.tileSize

var Npc : CharacterBody2D
var sprite : AnimatedSprite2D
var current_direction := Vector2.DOWN
var is_moving := false
var target_position := Vector2.ZERO

func initialize(p_sprite : AnimatedSprite2D, start_dir : Vector2) :
	sprite = p_sprite
	Npc = get_parent() as CharacterBody2D
	current_direction = start_dir
	target_position = Npc.global_position
	update_animation("idle")

func _physics_process(delta: float) -> void:
	if not is_moving :
		return 
	
	_process_movement(delta)

func _process_movement(delta : float) :
	var previous_pos = Npc.global_position
	Npc.global_position = Npc.global_position.move_toward(target_position, SPEED * delta)
	
	if Npc.global_position.distance_to(target_position) < 0.5:
		Npc.global_position = target_position
		stop()
		movement_completed.emit()

func move_to(destination : Vector2) -> bool :
	var motion = destination - Npc.global_position
	var collision = Npc.move_and_collide(motion, true)
	
	if collision : 
		return false
	
	var direction = (destination - Npc.global_position).normalized()
	_update_direction(direction)
	
	target_position = destination
	is_moving = true
	update_animation("Walking")
	movement_started.emit(current_direction)
	
	return true
	
func move_one_in_direction(direction : Vector2) -> bool : 
	var destination = Npc.global_position + direction * TileSize
	return (move_to(destination))

func stop() :
	is_moving = false
	update_animation("idle")

func teleport_to(position : Vector2):
	Npc.global_position = position
	target_position = position
	is_moving = false

func _update_direction(direction : Vector2):
	var new_direction = _snap_direction(direction)
	if new_direction != current_direction : 
		current_direction = new_direction
		direction_changed.emit(current_direction)
		
func _snap_direction(direction : Vector2) -> Vector2 :
	if abs(direction.x) > abs(direction.y):
		return Vector2.RIGHT if direction.x > 0 else Vector2.LEFT
	else:
		return Vector2.DOWN if direction.y > 0 else Vector2.UP

func update_animation(anim_type) :
	if not sprite :
		return 
		
	var prefix := ""
	if current_direction == Vector2.UP:
		prefix = "back"
	elif current_direction == Vector2.DOWN:
		prefix = "face"
	elif current_direction == Vector2.LEFT:
		prefix = "left"
	elif current_direction == Vector2.RIGHT:
		prefix = "right"
	
	if prefix:
		var anim_name = prefix + anim_type
		if sprite.sprite_frames.has_animation(anim_name):
			sprite.play(anim_name)

func get_position_ahead(distance: float = 16.0) -> Vector2:
	"""Retourne la position devant le NPC"""
	return Npc.global_position + current_direction * distance

func is_at_position(position: Vector2, tolerance: float = 1.0) -> bool:
	"""Vérifie si le NPC est à une position donnée"""
	return Npc.global_position.distance_to(position) < tolerance
