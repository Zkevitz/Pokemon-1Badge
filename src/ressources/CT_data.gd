extends Resource
class_name CT_data

enum Type { AUCUN, NORMAL, FEU, EAU, PLANTE, ELECTRIQUE, GLACE, COMBAT, POISON, SOL, VOL,
	 PSY, INSECTE, ROCHE, SPECTRE, DRAGON, TENEBRES, ACIER, FEE}
	
	
enum Effect {NONE, BURN, PARA, SLEEP, PSN, LOWER_ENEMY_ATK, LOWER_ENEMY_DEF, LOWER_ENEMY_ATKSPE, LOWER_ENEMY_DEFSPE, LOWER_ENEMY_SPEED,
			BOOST_TARGET_ATK, BOOST_TARGET_DEF, BOOST_TARGET_ATKSPE, BOOST_TARGET_DEFSPE, BOOST_TARGET_SPEED}

@export_group("base data")
@export var name := "Charge"
@export var id := 1
@export var type := Type.NORMAL
@export var category := "PHYSICS"
@export var power := 40
@export var accuracy := 100
@export var max_pp := 25
@export var priority := 0

@export_group("effect")
@export var type_effect := Effect.NONE
@export var power_effect := 1
@export var chance := 0





# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
