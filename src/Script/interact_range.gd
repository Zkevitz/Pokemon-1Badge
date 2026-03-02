extends Area2D

@onready var interactionCanva
@onready var dialogueUi
var player_nearby = false

@export var recompense_type : Game.recompenseType = Game.recompenseType.POKEMON 
@export var recompense_id : int = 1
@export var question_custom : String = "question test"

func _ready() -> void:
	dialogueUi = Game.GlobalUI.get_node("DialogueUI")

func _input(event):
	if player_nearby and event.is_action_pressed("interact") :
		
		if not DialogueManager.is_active():
			var img
			var need_to_free : bool = false
			if recompense_type == Game.recompenseType.POKEMON :
				var pokemon_data = Game.get_pokemon_data(recompense_id)
				need_to_free = true
				img = pokemon_data.sprite_frames.get_frame_texture("idle", 0)
				var result = await dialogueUi.askCustomQuestion(question_custom ,img)
				get_parent().visible = false
				print(get_parent())
				if result == true: 
					playerManager.player_instance.receiveGift(recompense_type, recompense_id)
					if need_to_free :
						queue_free()
						queue_free()
			elif recompense_type == Game.recompenseType.TEAM_HEALING :
				var result = await dialogueUi.askCustomQuestion(question_custom)
				if result :
					playerManager.player_instance.receiveGift(recompense_type)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") : 
		player_nearby = false
