extends Node2D


@onready var anim := %AnimationPlayer


func _ready() -> void:
	visible = false
	
	
func setup_anim():
	visible = false
	
func play_attack(sender : PokemonNode, receiver : PokemonNode, battle_ui : BattleUI):
	global_position = receiver.global_position
	visible = true
	anim.play("play_attack")
	SoundManager.play_sfx(preload("res://sound/SFX/attack_sfx/Vine Whip.mp3"), -10)
	await anim.animation_finished	
