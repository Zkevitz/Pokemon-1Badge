extends Node2D

@onready var animatedSprite : AnimatedSprite2D
@onready var animationPlayer : AnimationPlayer

var opponent_position 
var opponent_node : PokemonNode
var backGround = preload("res://assets/attackSprite/vibraquaBackground.tres")
func _ready() -> void:
	visible = false
	
func setup_anim()->void :
	print("move anim rentre en JEUXXX")
	animatedSprite = get_node("AnimatedSprite2D")
	animationPlayer = get_node("AnimationPlayer")
	visible = false

func play_receiver_ondulation():
	opponent_node.horizontal_ondulation(0.5)
	
func play_attack(sender : PokemonNode, receiver : PokemonNode, battle_ui : BattleUI):
	global_position = sender.global_position
	opponent_node = receiver
	opponent_position = receiver.global_position
	var actual_battle_background = battle_ui.BackgroundTexture.texture
	battle_ui.BackgroundTexture.texture = backGround
	await get_tree().create_timer(0.2).timeout
	visible = true
	animationPlayer.play("play_attack")
	await animationPlayer.animation_finished
	battle_ui.BackgroundTexture.texture = actual_battle_background

func play_attack_sfx1():
	SoundManager.play_sfx(preload("res://sound/SFX/attack_sfx/Water Pulse.mp3"), -10)
	
func Send_to_ennemy() :
	var tween = create_tween()
	
	tween.tween_property(self, "global_position", opponent_position, 1.0)
