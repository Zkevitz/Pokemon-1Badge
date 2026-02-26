extends Area2D
class_name ChangeSceneComponent

@export var destination_name : String = "MainWorld"
@export var destination_pos : Vector2 = Vector2(33, 33)
@export var direction_input := "forward"


var player_nearby := false
var is_entering := false
var destination_scene
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _process(_delta: float) -> void:
	if player_nearby and Input.is_action_pressed(direction_input) and is_entering == false:
		is_entering = true
		await Game.change_scene_with_player(Game.current_node ,destination_name, destination_pos)
		is_entering = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print(destination_scene)
		print(destination_pos)
		player_nearby = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		is_entering = false
