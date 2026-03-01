extends Node2D

@onready var particule := %GPUParticles2D

func _ready() -> void:
	visible = false

func setup_anim():
	visible = false
	
func play_attack(sender : PokemonNode, receiver : PokemonNode, battleui : BattleUI):
	global_position = sender.global_position
	look_at(receiver.global_position)
	
	visible = true
	particule.emitting = true
	await get_tree().create_timer(0.3).timeout
	SoundManager.play_sfx(preload("res://sound/SFX/attack_sfx/Water Gun.mp3"), -10)
	await particule.finished
	
