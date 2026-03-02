extends Node2D

var pokemon: PokemonNode


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func play_attack(sender : PokemonNode, receiver : PokemonNode, battleui : BattleUI):
	pokemon = receiver
	global_position = receiver.global_position
	visible = true
	$AnimationPlayer.play("RESET")
	SoundManager.play_sfx(preload("res://sound/SFX/attack_sfx/Thunder Punch.mp3"), -10)
	battleui.flash_screen(2, Color(1, 1, 0, 0.0))
	await $AnimationPlayer.animation_finished

func setup_anim() ->void :
	visible = false


func change_pokemon_color() -> void:
	pokemon.flash_color(Color(1, 1, 1), 0.5)
