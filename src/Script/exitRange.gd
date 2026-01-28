extends Area2D

var playerNearby := false


func _ready() -> void:
	pass # Replace with function body.


func _process(_delta: float) -> void:
	if playerNearby and Input.is_action_pressed("backward"):
		exit_building()

func exit_building() -> void :
	var destination_Node : Node2D = Game.returnScene
	var hidden_Node : Node2D = Game.actualNode
	print("dest node : ", destination_Node)
	print("hidden node :", hidden_Node)
	Game.toggleWorld(destination_Node, hidden_Node)
	#playerManager.remove_player_from_scene()
	#get_tree().change_scene_to_file(destinationScene)

func _on_body_entered(body: Node2D) -> void:
	print("body entered")
	if body.is_in_group("player"):
		playerNearby = true


func _on_body_exited(body: Node2D) -> void:
	print("body exited")
	if body.is_in_group("player"):
		playerNearby = false
