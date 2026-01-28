extends Area2D

@onready var grassAnim := $AnimatedSprite2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	grassAnim.play("down")
	if not body.is_in_group("player") :
		return
	var encounter_chance = randi() % 100
	if encounter_chance <= 10 :
		await get_tree().process_frame
		playerManager.desacPlayer()
		Game.start_wild_battle()
	pass # Replace with function body.


func _on_body_exited(_body: Node2D) -> void:
	grassAnim.play("up")
	pass # Replace with function body.
