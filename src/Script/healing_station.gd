extends StaticBody2D

@onready var interaction := $InteractableObject

var dialogueUi
func _ready() -> void:
	dialogueUi = Game.GlobalUI.get_node("DialogueUI")
	interaction.interaction = _heal_player_team


func _heal_player_team():
	var result = await dialogueUi.askCustomQuestion("Souhaitez vous soigner vos Pokemon ?")
	if result:
		playerManager.player_instance.receiveGift(Game.recompenseType.TEAM_HEALING)
		await DialogueManager.input_pressed
