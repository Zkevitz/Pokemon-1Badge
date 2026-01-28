extends Area2D

@onready var interactionCanva
@onready var dialogueUi
var player_nearby = false

@export var recompense_type : Game.recompenseType = Game.recompenseType.POKEMON 
@export var recompense_id : int = 1
@export var question_custom : String = "question test"

func _ready() -> void:
	interactionCanva = get_tree().current_scene.get_node("DialogueUI/InteractionCanva")
	dialogueUi = get_tree().current_scene.get_node("DialogueUI")

#var dialogues = {
	#"professeur Homes" : [
	#{"speaker": "Prof", "text": "Salut {nom du joeur pas encore implementer}, C'est le grand jour pour toi"},
	#{"speaker": "Prof", "text": "tu vas pouvoir choisir un des trois pokemon sur la table"},
	#{"speaker": "Prof", "text": "fais bien attention a ton choix la vie au dela des mur du village est rude"}
#]}
func _input(event):
	if player_nearby and event.is_action_pressed("interact") :
		if not DialogueManager.is_active():
			var pokemon_data = Game.get_data(recompense_id)
			var img
			var need_to_free : bool = false
			if recompense_type == Game.recompenseType.POKEMON :
				need_to_free = true
				img = pokemon_data.sprite_frames.get_frame_texture("idle", 0)
			var result = await dialogueUi.askCustomQuestion(question_custom ,img)
			
			if result == true: 
				playerManager.player_instance.receiveGift(recompense_type, recompense_id)
				if need_to_free :
					queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") : 
		player_nearby = false
