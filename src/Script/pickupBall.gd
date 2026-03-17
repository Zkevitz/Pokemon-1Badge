extends Sprite2D

@export var recompenseType : Game.recompenseType = Game.recompenseType.POKEMON
@export var recompenseId : int = 1

@onready var interaction := $InteractableObject

var dialogueUi

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interaction.interaction = give_player_recompense
	dialogueUi = Game.GlobalUI.get_node("DialogueUI")
	pass # Replace with function body.


func give_player_recompense():
	if DialogueManager.is_active():
		return
	
	match recompenseType :
		Game.recompenseType.POKEMON :
			var pokemon_data = Game.get_pokemon_data(recompenseId)
			var img = pokemon_data.sprite_frames.get_frame_texture("idle", 0)
			var result = await dialogueUi.askCustomQuestion("Voulez vous prendre %s ?" % pokemon_data.pokemon_name ,img)
			if result: 
				self._give_pokemon()
		Game.recompenseType.OBJECT :
			pass
			
func _give_pokemon() -> void:
	playerManager.player_instance.receiveGift(recompenseType, recompenseId)
	StoryManager.set_flag(StoryManager.Flag.HAS_POKEMON)
	visible = false
	queue_free()
