extends Area2D

@onready var interactionCanva
@onready var dialogueUi
var player_nearby = false

@export var recompense_type : Game.recompenseType = Game.recompenseType.POKEMON 
@export var recompense_id : int = 1
@export var question_custom : String = "question test"

func _ready() -> void:
	dialogueUi = Game.GlobalUI.get_node("DialogueUI")

func _get_starter_pokemon() -> void:
	playerManager.player_instance.receiveGift(recompense_type, recompense_id)
	StoryManager.set_flag(StoryManager.Flag.HAS_POKEMON)
	get_parent().visible = false
	queue_free()

func _input(event):
	if not player_nearby or not event.is_action_pressed("interact"):
		return
	if DialogueManager.is_active():
		return
	match recompense_type:
		Game.recompenseType.POKEMON:
			var img = Game.get_pokemon_data(recompense_id).sprite_frames.get_frame_texture("idle", 0)
			var result = await dialogueUi.askCustomQuestion(question_custom ,img)
			if result: 
				self._get_starter_pokemon()
		Game.recompenseType.TEAM_HEALING:
			var result = await dialogueUi.askCustomQuestion(question_custom)
			if result:
				playerManager.player_instance.receiveGift(recompense_type)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") : 
		player_nearby = false
