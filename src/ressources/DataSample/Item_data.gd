extends Resource
class_name Item_data

enum ItemCat {POTION, BALL, HELD}
enum ItemEffect {PVHEAL, STATUSHEAL, CATCH}

@export var Item_name := "Default"
@export var Categorie : ItemCat
@export var Description : String
@export var effect : ItemEffect	
@export var effect_power : float
@export var max_stack : int = 64
@export var icon : Texture2D = load("res://assets/npc/MPWSP01/mypokeball.png")
