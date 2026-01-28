extends Node2D

@export var SpawnPosition := Vector2(9, 8)
@onready var floorLayer := $floor
@onready var SortingLayer := $ysortingnode

func _ready() -> void:
	var notSortingLayer = SortingLayer.get_parent()
	playerManager.toggleScene(notSortingLayer)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
