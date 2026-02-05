extends Area2D

var player_nearby := false
var isEntering := false

@export var destination_scene_packed = preload("res://src/node/first_forest.tscn")
@export var destination_pos : Vector2 = Vector2(33, 33)
@export var direction_input : String = "forward"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("===== PORTE ACTIVÉE =====")
	print("Nom du node: ", name)
	print("Parent: ", get_parent().name)
	print("Scène: ", get_tree().current_scene.name)
	print("Chemin complet: ", get_path())
	print("========================")
	add_to_group("doors")  # AJOUTEZ CETTE LIGNE
	print("Porte prête: ", name, " dans ", get_tree().current_scene.name)
	
	# Vérifiez que les signaux sont connectés
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player_nearby and Input.is_action_just_pressed(direction_input) and !isEntering:
		isEntering = true
		Game.call_deferred("change_scene_with_player", destination_scene_packed, destination_pos)
		#Game.change_scene_with_player(destination_scene_packed, destination_pos)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		isEntering = false
