extends Node2D
class_name PokemonNode

enum Type { AUCUN, NORMAL, FEU, EAU, PLANTE, ELECTRIQUE, GLACE, COMBAT, POISON, SOL, VOL,
	 PSY, INSECTE, ROCHE, SPECTRE, DRAGON, TENEBRES, ACIER, FEE}

@export_group("Comportements")
@export var is_wild : bool = true
@export var can_move : bool = false

var pokemonInstance : PokemonInstance

var animatedSprite : AnimatedSprite2D
var animation_player : AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if pokemonInstance.data.sprite_frames :
		animatedSprite.sprite_frames = pokemonInstance.data.sprite_frames
	animatedSprite.play("idle")
	
func setup(instance : PokemonInstance):
	pokemonInstance = instance
	animatedSprite = get_node("AnimatedSprite2D")
	animation_player = get_node("AnimationPlayer")
	if pokemonInstance.data.sprite_frames :
		animatedSprite.sprite_frames = pokemonInstance.data.sprite_frames
	animatedSprite.play("idle")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
