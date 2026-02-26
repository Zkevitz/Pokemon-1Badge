extends Node
class_name NPCInteraction

signal interaction_triggered
signal dialogue_started
signal dialogue_ended

@export var has_dialogue := true
@export var dialogue_id := ""
@export var is_interactive := true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
