extends Node2D



@onready var anim := %AnimationPlayer
@onready var particuleSended := $GPUParticles2D2


func _ready() -> void:
	visible = false
	
func setup_anim():
	visible = false
	
func play_attack(sender : PokemonNode, receiver : PokemonNode, battle_ui : BattleUI):
	global_position = sender.global_position
	particuleSended.look_at(receiver.global_position)
	visible = true
	anim.play("play_attack")
	SoundManager.play_sfx(preload("res://sound/SFX/attack_sfx/Magical Leaf.mp3"), -15)
	await anim.animation_finished	
