extends Node2D

func _ready() -> void:
	visible = false
	
func setup_anim()->void :
	visible = false
	for child in get_children() :
		child.material.set_shader_parameter("flash_color", Color("#7a00ff"))
		child.material.set_shader_parameter("flash_amount", 0.65)
	
func play_attack(sender : PokemonNode, receiver : PokemonNode, battleui : BattleUI):
	
	var receiver_pos = receiver.global_position
	global_position = receiver.global_position
	global_position.y -= 90
	visible = true

	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position:y", receiver_pos.y + 30, 2.5)
	SoundManager.play_sfx(preload("res://sound/SFX/attack_sfx/Poison Powder.mp3"), -10)
	await tween.finished
	visible = false
	
