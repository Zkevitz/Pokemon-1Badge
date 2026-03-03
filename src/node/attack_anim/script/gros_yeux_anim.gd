extends Node2D

@onready var anim := $AnimatedSprite2D

func _ready() -> void:
	visible = false
	
func setup_anim():
	visible = false
	
func play_attack(sender : PokemonNode, receiver : PokemonNode, battle_ui : BattleUI):
	global_position = sender.global_position
	global_position.y -= 20
	global_position.x += 20
	visible = true
	anim.play("default")
	SoundManager.play_sfx(preload("res://sound/SFX/attack_sfx/Leer.mp3"), -15)
	await anim.animation_finished	
	
