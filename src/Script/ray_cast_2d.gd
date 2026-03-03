extends RayCast2D
class_name RayCastComponent

enum eventType {LOCK1, BATTLE, GIFT, RIVAL}
@onready var pnj = get_parent()
@export var EventType : eventType = eventType.LOCK1
var player_detected = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("ATTENTION PNJ = :", pnj)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if is_colliding() and get_collider().is_in_group("player"):
			if not player_detected  :
				match EventType:
					eventType.LOCK1 : await _on_lock()
					eventType.BATTLE : await _on_battle()
					eventType.GIFT : await _on_gift()


func _on_lock() -> void:
	if playerManager.player_instance.pokemonTeam.size() == 0:
		await pnj.block_player_way(1)


func _on_battle() -> void:
	print("try to start battle ?")
	await pnj.block_player_way(1)


func _on_gift() -> void:
	if StoryManager.get_flag("has_pokemon") and not StoryManager.get_flag("keeper_gift_done"):
		await pnj.block_player_way(0)
		StoryManager.set_flag("keeper_gift_done")


func _on_rival() -> void:
	pass
	# Deactivate player
	# Activate Rivale visibility
	# Make Rival goto player
	# Talk
	# Combat
