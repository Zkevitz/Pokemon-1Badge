extends Node
class_name NpcMovementComponent

const SPEED := 30
const TIME_BETWEEN_MOVE := 3.0

signal movement_ended

var _npc : CharacterBody2D
var _animator : NpcAnimationComponent
var target_position : Vector2
var mouvement_timer := 0.0
var AreaSize : Rect2
var _moving_area : Area2D


func setup(npc: CharacterBody2D) -> void:
	_npc = npc
	_animator = npc.get_node("NpcAnimationComponent")
	_moving_area = npc.get_node_or_null("MovingArea")


func go_to(pos: Vector2) -> void:
	target_position = pos
	_npc.currentState = _npc.animState.MOVING
	_npc.set_physics_process(true)
	await movement_ended
	_npc.currentState = _npc.animState.IDLE
	_npc.set_physics_process(false)


func handle_moving(delta: float) -> void:
	_animator.play("Walking")
	_npc.global_position = _npc.global_position.move_toward(target_position, SPEED * delta)
	if _npc.global_position.distance_to(target_position) < 0.5:
		_npc.global_position = target_position
		_npc.currentState = _npc.animState.IDLE
		_animator.play("idle")
		mouvement_timer = TIME_BETWEEN_MOVE
		movement_ended.emit()


func handle_idle(delta: float) -> void:
	if _moving_area == null:
		return
	mouvement_timer -= delta
	_animator.play("idle")
	if mouvement_timer > 0.0:
		return
	var area_pos = _moving_area.global_position
	var area_rect = Rect2(area_pos - AreaSize.size / 2.0, AreaSize.size)
	var dirs = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
	dirs.shuffle()
	for dir in dirs:
		var candidate = _npc.global_position + dir * Game.tileSize
		if _is_inside_area(candidate, area_rect):
			target_position = candidate
			_npc.currentState = _npc.animState.MOVING
			_npc.move_direction = dir
			return
		target_position = _npc.global_position


func _is_inside_area(candidate: Vector2, area_rect: Rect2) -> bool:
	var motion = candidate - _npc.global_position
	var collision = _npc.move_and_collide(motion, true)
	if collision:
		return false
	return area_rect.has_point(candidate)
