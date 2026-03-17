extends Sprite2D

@export var recompenseId : String = ""
@onready var interactComponent := $InteractableObject

var tileSize = Game.tileSize


func _ready() -> void:
	@warning_ignore("integer_division")
	global_position = (global_position / tileSize).floor() * tileSize + Vector2(tileSize/2, tileSize/2)
	interactComponent.interaction = _give_object_to_player

func _give_object_to_player():
	var player = playerManager.player_instance
	
	player.receiveGift(Game.recompenseType.OBJECT, recompenseId)
	queue_free()
