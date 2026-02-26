extends PathFollow2D

const SPEED := 50
@onready var path := get_parent() as Path2D
@onready var childpnj : CharacterBody2D

var last_direction := Vector2.RIGHT


func _ready() -> void:
	childpnj = get_child(0) as CharacterBody2D
	
	childpnj.global_position = global_position
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Simuler la progression future
	var previous_pos = global_position
	var simulated_progress = progress + SPEED * delta

	if loop:
		var length = path.curve.get_baked_length()
		simulated_progress = fmod(simulated_progress, length)

	# Sauvegarder l'état
	var current_progress = progress

	# Aller à la position simulée
	progress = simulated_progress
	var direction = global_position - previous_pos
	if direction.length() > 0.1:
		direction = direction.normalized()
		last_direction = direction
	childpnj.move_direction = last_direction
	
	var next_position = global_position

	# Restaurer la vraie position
	progress = current_progress

	# Donner une vraie cible au PNJ
	childpnj.target_position = next_position

	# Laisser le PNJ gérer le mouvement
	if childpnj.handle_path_moving(delta):
		childpnj.global_position = previous_pos
		return

	# Appliquer la progression réelle
	progress = simulated_progress
