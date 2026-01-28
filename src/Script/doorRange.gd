extends Area2D

@export var destinationScene := "HouseInterior2"
@export var closeScene := "MainWorld"

var playerNearby := false
var isEntering := false


func _ready() -> void:
	pass # Replace with function body.


func _process(_delta: float) -> void:
	#print(get_parent())
	if playerNearby and Input.is_action_pressed("forward") and isEntering == false:
		isEntering = true
	if isEntering == true :
		enter_building()

func enter_building() -> void :
	#Game.returnPosition = Vector2i(playerManager.player_instance.global_position / 16)
	print("Game returnpos : ", Game.returnPosition)
	Game.returnScene = get_tree().current_scene.get_node(closeScene)
	var destination_Node = get_tree().current_scene.get_node(destinationScene)
	Game.actualNode = destination_Node
	var HiddenNode = Game.returnScene
	print("enter building global var at :", Game.returnScene, Game.actualNode)
	Game.toggleWorld(destination_Node, HiddenNode)
	# DEBUG
	#print("destination_Node y sorting node : ", destination_Node.get_node("ysortingnode"))
	#print("before reparent : ", playerManager.player_instance.get_parent())
	#print("after reparent : ", playerManager.player_instance.get_parent())
	#print("closed Scene is : ", HiddenNode)
	#print("Open scene is : ", destination_Node)
	#print("player take entry")
	isEntering = false
	
func _on_body_entered(body: Node2D) -> void:
	print("body entered")
	if body.is_in_group("player"):
		playerNearby = true
	pass # Replace with function body.


func _on_body_exited(body: Node2D) -> void:
	print("body exited")
	if body.is_in_group("player"):
		playerNearby = false
	pass # Replace with function body.
