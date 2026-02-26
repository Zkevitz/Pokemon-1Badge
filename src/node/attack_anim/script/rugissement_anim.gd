extends Node2D


@onready var anim := $AnimationPlayer

func _ready() -> void:
	visible = false
	
func setup_anim()->void :
	visible = false

func play_attack(sender : PokemonNode, receiver : PokemonNode, battleui : BattleUI):
	if sender.is_opponent : 
		global_position = sender.global_position
		global_position.x -= 60
		rotation_degrees = -190
	else :
		rotation_degrees = -25
		global_position = sender.global_position
		global_position.x += 20
	print("rotation for node is : ", rotation)
	visible = true 
	anim.play("play_attack")
	SoundManager.play_sfx(preload("res://sound/SFX/attack_sfx/Growl.mp3"), -15)
	await anim.animation_finished
