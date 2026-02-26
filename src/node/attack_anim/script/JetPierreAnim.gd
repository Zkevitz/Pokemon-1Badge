extends Node2D

@onready var animatedSprite : AnimatedSprite2D
@onready var animationPlayer : AnimationPlayer



func setup_anim()->void :
	print("move anim rentre en JEUXXX")
	animatedSprite = get_node("AnimatedSprite2D")
	animationPlayer = get_node("AnimationPlayer")
	visible = false
	#animationPlayer.play("RESET")
	
func play_attack(attacker : PokemonNode, receiver : PokemonNode, battleUi : BattleUI):
	print("why not working")
	global_position = receiver.global_position
	global_position.y -= 250
	visible = true
	animationPlayer.play("RESET")
	await animationPlayer.animation_finished
	
	await receiver.vertical_shake()

func play_attack_sfx():
	SoundManager.play_sfx(preload("res://sound/SFX/attack_sfx/Rollout_rock_throw.mp3"), -10)
