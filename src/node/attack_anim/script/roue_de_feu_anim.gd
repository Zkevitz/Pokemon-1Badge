extends Node2D

@onready var anim := $AnimationPlayer
@onready var prep_anim := $PrepComp
@onready var hit_anim := $GPUParticles2D

var opponent : PokemonNode
var Sender : PokemonNode
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	hit_anim.emitting = false

func setup_anim()->void :
	visible = false

func play_attack(sender : PokemonNode, receiver : PokemonNode, battleui : BattleUI):
	prep_anim.global_position = sender.global_position
	hit_anim.global_position = receiver.global_position
	Sender = sender
	
	visible = true 
	anim.play("play_attack")
	SoundManager.play_sfx(preload("res://sound/SFX/attack_sfx/Flame WheelPart1.mp3"), -10)
	await anim.animation_finished

func play_hit_anim():
	hit_anim.emitting = true
	SoundManager.play_sfx(preload("res://sound/SFX/attack_sfx/Flame Wheel.mp3"), -10)
	
func send_prep_attack():
	var attack_dir = -30 if Sender.is_opponent else 30
	Sender.make_attack_move(attack_dir)
