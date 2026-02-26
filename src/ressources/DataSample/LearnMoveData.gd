extends Resource
class_name MoveLearnData

enum Type { BASE, LEVEL, CT, EGG, TUTOR}

@export var move_id := 1
@export var LearnType : Type = Type.BASE
@export var LevelRequired : int = 1
