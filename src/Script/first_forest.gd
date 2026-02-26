extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("je suis pret forst")
	Game.current_node = self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
