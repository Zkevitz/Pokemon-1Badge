extends Node2D

@onready var animatedSprite : AnimatedSprite2D



func setup_anim()->void :
	animatedSprite = get_node("Sprite2D")
	visible = false
	
func play_attack(sender : PokemonNode, receiver : PokemonNode, battleui : BattleUI):
	global_position = receiver.global_position
	visible = true
	animatedSprite.play("default")
	await receiver.flash_color(Color.RED ,1.4)
	await animatedSprite.animation_finished
	
func play_burn(receiver : PokemonNode) :
	global_position = receiver.global_position
	visible = true
	animatedSprite.play("default")
	SoundManager.play_sfx(preload("res://sound/SFX/attack_sfx/Ember.mp3"), -10)
	await animatedSprite.animation_finished
