extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if playerManager.player_instance == null :
		playerManager.player_instance = preload("res://src/node/charac/mainChar.tscn").instantiate()
		self.add_child(playerManager.player_instance)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
