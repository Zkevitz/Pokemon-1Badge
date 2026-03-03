extends RayCast2D
class_name RayCastComponent

enum eventType {LOCK1, BATTLE, GIFT}
@onready var pnj = get_parent()
@export var EventType : eventType = eventType.LOCK1
var player_detected = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("ATTENTION PNJ = :", pnj)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if is_colliding():
		var collider = get_collider()
		if collider.is_in_group("player"):
			if not player_detected  :
				player_detected = true
				if EventType == eventType.LOCK1 :
					if playerManager.player_instance.pokemonTeam.size() == 0:
						await pnj.block_player_way(0)
				elif EventType == eventType.BATTLE :
					print("try to start battle ? ")
					await pnj.block_player_way(1)
				elif EventType == eventType.GIFT:
					await pnj.block_player_way(0)
					StoryManager.set_flag("keeper_gift_done")
	else:
		if player_detected:
			player_detected = false
