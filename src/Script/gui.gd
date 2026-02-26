extends Control

@onready var DialogueUi := $DialogueUI
@onready var TransitionFade := $TransitionFade
@onready var MenuUi := $MenuUi
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Game.GlobalUI = self
	pass # Replace with function body.

func get_DialogueUi() :
	return DialogueUi
