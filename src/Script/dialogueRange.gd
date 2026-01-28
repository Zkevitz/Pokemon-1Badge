extends Area2D


@export var dialogue_id = "professeur Homes"
@onready var pnjNode : CharacterBody2D
@onready var interactionCanva
@onready var dialogueUi
var player_nearby = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactionCanva = get_tree().current_scene.get_node("DialogueUI/InteractionCanva")
	dialogueUi = get_tree().current_scene.get_node("DialogueUI")
	pnjNode = get_parent()
	print(pnjNode)
	print(interactionCanva)

func _input(event):
	#print(event.is_action_pressed("interact"))
	#print("player nearby ? : ", player_nearby)
	if player_nearby and event.is_action_pressed("interact"):
		if not DialogueManager.is_active():
			DialogueManager.startDialogue(dialogue_id)
			interactionCanva.hide_prompt()
		elif DialogueManager.is_active():
			dialogueUi.input_pressed()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("body entered")
		player_nearby = true
		pnjNode.set_physics_process(false)
		interactionCanva.show_prompt()


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("body exited")
		player_nearby = false
		if pnjNode.hasToMove == true:
			pnjNode.set_physics_process(true)
		interactionCanva.hide_prompt()
