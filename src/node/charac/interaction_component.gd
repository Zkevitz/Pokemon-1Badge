extends Node2D

@onready var InteractShape := $CollisionShape2D

var player : CharacterBody2D
var current_interaction := []
var is_interactable := true 

func _ready() -> void:
	player = get_parent()
	pass

func _input(event: InputEvent) -> void:
	if is_interactable and event.is_action_pressed("interact"):
		if current_interaction :
			is_interactable = false
			await current_interaction[0].interaction.call()
			is_interactable = true


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("interactingObject") :
		current_interaction.push_back(area)


func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("interactingObject") :
		current_interaction.erase(area)

func _on_sprite_2d_animation_changed() -> void:
	match player.current_direction :
		Vector2.DOWN :
			InteractShape.position = Vector2(0, 16)
		Vector2.UP :
			InteractShape.position = Vector2(0, -16)
		Vector2.LEFT : 
			InteractShape.position = Vector2(-16, 0)
		Vector2.RIGHT :
			InteractShape.position = Vector2(16, 0)
