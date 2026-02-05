extends Area2D

@onready var grassAnim := $AnimatedSprite2D

var returnPos : Vector2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var player_inside = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if player_inside == true : 
		print("lol")
	pass


func _on_body_entered(body: Node2D) -> void:
	grassAnim.play("down")
	if not body.is_in_group("player") :
		return
	player_inside = true
	var encounter_chance = randi() % 100
	if encounter_chance <= 10 :
		await get_tree().process_frame
		playerManager.desacPlayer()
		returnPos = Vector2i(global_position / Game.tileSize)
		returnPos.y -= 1
		print("returning pos : ", returnPos)
		Game.start_wild_battle()
		playerManager.teleport_to(get_parent().get_parent(), returnPos)
	pass # Replace with function body.


func _on_body_exited(_body: Node2D) -> void:
	grassAnim.play("up")
	pass # Replace with function body.
