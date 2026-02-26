extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Game.current_node = self
	print("game. current_node : ", Game.current_node)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
