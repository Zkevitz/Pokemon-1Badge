extends Node2D


@onready var particule := %GPUParticles2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	
func setup_anim():
	visible = false
	
func play_attack(sender : PokemonNode, receiver : PokemonNode, battleui : BattleUI):
	global_position = sender.global_position
	look_at(receiver.global_position)
	
	visible = true
	particule.emitting = true
	SoundManager.play_sfx(preload("res://sound/SFX/attack_sfx/Bubble Beam part 1.mp3"), -10)
	await get_tree().create_timer(1.7).timeout
	particule.emitting = false
	
