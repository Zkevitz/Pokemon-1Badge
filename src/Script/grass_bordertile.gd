extends StaticBody2D
class_name BorderJump

@export var jump_direction: Vector2 = Vector2.UP
@export var jump_height: float = 16.0
@export var jump_duration: float = 0.5

var passable_from: Vector2

func get_opposite_direction(dir: Vector2) -> Vector2:
	match dir:
		Vector2.UP : return Vector2.DOWN
		Vector2.DOWN: return Vector2.UP
		Vector2.LEFT: return Vector2.RIGHT
		Vector2.RIGHT: return Vector2.LEFT
	return Vector2.DOWN
	
func _ready() -> void:
	passable_from = get_opposite_direction(jump_direction)

func can_player_pass(player_direction : Vector2) -> bool :
	return player_direction == passable_from

func get_jump_offset() -> Vector2:
	match jump_direction:
		Vector2.DOWN: return Vector2(0, -16)
		Vector2.UP: return Vector2(0, 16)
		Vector2.LEFT: return Vector2(16, 0)
		Vector2.RIGHT: return Vector2(-16, 0)
	return Vector2.ZERO
