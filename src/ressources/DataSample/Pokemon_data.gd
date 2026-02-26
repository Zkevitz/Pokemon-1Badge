extends Resource
class_name PokemonData

enum Type { AUCUN, NORMAL, FEU, EAU, PLANTE, ELECTRIQUE, GLACE, COMBAT, POISON, SOL, VOL,
	 PSY, INSECTE, ROCHE, SPECTRE, DRAGON, TENEBRES, ACIER, FEE}

@export_group("identity")
@export var pokemon_name : String = "grasspokemon"
@export var pokemon_id : int = 1
@export var sprite_frames : SpriteFrames
@export var pokemon_type1 : Type = Type.NORMAL
@export var pokemon_type2 : Type = Type.AUCUN

@export_group("Stats de base")
@export var baseHp : int = 35
@export var baseAtk : int = 55
@export var baseSpeAtk : int = 31
@export var baseDef : int = 40
@export var baseSpeDef : int = 33
@export var baseSpd : int = 42
@export var level : int = 1
@export var base_exp_yield: int = 50

@export var learnable_moves : Array[MoveLearnData]


func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
