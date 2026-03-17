extends StaticBody2D

@export var textToDisplay = ""
@onready var interaction := $InteractableObject

var tileSize = Game.tileSize

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	@warning_ignore("integer_division")
	global_position = (global_position / tileSize).floor() * tileSize + Vector2(tileSize/2, tileSize/2)
	interaction.interaction = _show_sign_text

func _show_sign_text():
	DialogueManager.startDialogue(textToDisplay)
