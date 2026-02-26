extends Node2D


@onready var anim := $AnimationPlayer


func _ready() -> void:
	visible = false
	
func setup_anim()->void :
	visible = false

func play_attack(sender : PokemonNode, receiver : PokemonNode, battleui : BattleUI):
	global_position = receiver.global_position
	global_position.y -= 50
	
	visible = true
	anim.play("play_attack")
	SoundManager.play_sfx(preload("res://sound/SFX/attack_sfx/Thunder Wave.ogg"), -10)
	await anim.animation_finished
