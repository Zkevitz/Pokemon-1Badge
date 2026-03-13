extends Resource
class_name CT_data
	
enum Effect {NONE, BURN, PARA, SLEEP, PSN, CFN, LOWER_TARGET_STAT, BOOST_TARGET_STAT, HIGH_CRIT_RATE}
enum TargetChoice {SELF, ENEMY}
enum Categorie {PHYSICS, SPECIAL, STATUS}

@export_group("base data")
@export var name := "Charge"
@export var id := 1
@export var type := PokemonData.Type.NORMAL
@export var category := Categorie.PHYSICS
@export var power := 40
@export var accuracy := 100
@export var max_pp := 25
@export var priority := 0

@export_group("effect")
@export var type_effect := Effect.NONE
@export var Stat_action := "Atk_dict"
@export var target := TargetChoice.ENEMY
@export var power_effect := 1
@export var chance := 0

@export_group("animation")
@export var AnimNode : PackedScene
