extends Node
class_name NpcAnimationComponent

var _anim : AnimatedSprite2D
var _npc : CharacterBody2D


func setup(npc: CharacterBody2D) -> void:
	_npc = npc
	_anim = npc.get_node("NpcSprite")


func play(type: String) -> void:
	var dir = _npc.move_direction
	var prefix := ""
	if dir == Vector2.UP: prefix = "back"
	elif dir == Vector2.DOWN: prefix = "face"
	elif dir == Vector2.LEFT: prefix = "left"
	elif dir == Vector2.RIGHT: prefix = "right"
	if prefix:
		var anim_name = prefix + type
		if _anim.animation != anim_name or not _anim.is_playing():
			_anim.play(prefix + type)
