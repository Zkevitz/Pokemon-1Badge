extends Node2D

func _ready() -> void:
	visible = false
func setup_anim()->void :
	visible = false
	print("move anim rentre en JEUXXX")
	#animationPlayer.play("RESET")

func play_attack(sender : PokemonNode, receiver : PokemonNode, battleui : BattleUI):
	var receiver_pos = receiver.global_position
	global_position = receiver.global_position
	global_position.y -= 90
	visible = true

	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position:y", receiver_pos.y + 30, 1.5)
	SoundManager.play_sfx(preload("res://sound/SFX/attack_sfx/Spore.mp3"), -10)
	await tween.finished
	visible = false
	
