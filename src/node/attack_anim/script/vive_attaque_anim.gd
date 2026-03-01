extends Node2D

@onready var anim := $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	
func setup_anim() ->void :
	visible = false

func play_attack(sender : PokemonNode, receiver : PokemonNode, battleui : BattleUI):
	global_position = receiver.global_position
	
	visible = true 
	anim.play("play_attack")
	SoundManager.play_sfx(preload("res://sound/SFX/attack_sfx/Quick Attack.mp3"), -10)
	await anim.animation_finished
