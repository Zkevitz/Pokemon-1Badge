extends Area2D

@onready var grassAnim := $AnimatedSprite2D

const sound = {
	"grass" : [
		preload("res://sound/SFX/grassStep/GRASS - Walk 1.wav"),
		preload("res://sound/SFX/grassStep/GRASS - Walk 2.wav"),
		preload("res://sound/SFX/grassStep/GRASS - Walk 3.wav"),
		preload("res://sound/SFX/grassStep/GRASS - Walk 4.wav"),
		preload("res://sound/SFX/grassStep/GRASS - Walk 5.wav"),
		preload("res://sound/SFX/grassStep/GRASS - Walk 6.wav"),
		preload("res://sound/SFX/grassStep/GRASS - Walk 7.wav"),
		preload("res://sound/SFX/grassStep/GRASS - Walk 8.wav")
	]
}
var returnPos : Vector2
var player_inside = false


func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func load_wild_encounter() :
	playerManager.desacPlayer()
	print("load wild encounter get parent ? : ", get_parent())
	returnPos = Vector2i(global_position / Game.tileSize)
	#returnPos.y -= 1
	print("returning pos : ", returnPos)
	Game.start_wild_battle()
	playerManager.teleport_to(returnPos)
		
func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") :
		return
	grassAnim.play("down")
	SoundManager.play_sfx(sound["grass"].pick_random(), -25)
	player_inside = true
	var encounter_chance = randi() % 100
	if encounter_chance <= 10 :
		await playerManager.player_instance.movement_finished
		load_wild_encounter()


func _on_body_exited(_body: Node2D) -> void:
	grassAnim.play("up")
	pass # Replace with function body.
