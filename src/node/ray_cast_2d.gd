extends RayCast2D

@onready var pnj = get_parent()
var player_detected = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("ATTENTION PNJ = :", pnj)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	if is_colliding():
		var collider = get_collider()
		
		if collider.is_in_group("player"):
			if not player_detected  :
				player_detected = true
				if playerManager.player_instance.pokemonTeam.size() == 0:
					pnj.show_exclamation_mark()
	else:
		if player_detected:
			player_detected = false
