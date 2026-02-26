extends Area2D
class_name GameZone

@export var zone_name := "Astrub"
@export var music_path : String = "res://sound/musics/First_town_audio(Day).mp3"
@export var zone_id := 1
@export var encounters_ids : Dictionary = {
	"grass" : {
		"COMMON" : [10, 14, 11, 23],
		"UNCOMMON" : [1, 4, 7],
		"RARE" : [18]
	}
}
@export var zone_level_range : Vector2i = Vector2i(3, 8)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	pass # Replace with function body.

func get_zone_level_range()-> Vector2i :
	return zone_level_range
	
func get_random_encounters(cell_type : String):
	var roll := randf()
	
	var pool : Array
	 
	if roll < 0.01 :
		pool = encounters_ids[cell_type]["RARE"]
	elif roll < 0.06 :
		pool = encounters_ids[cell_type]["UNCOMMON"]
	else :
		pool = encounters_ids[cell_type]["COMMON"]

	return pool.pick_random()
	
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("play music zone")
		playerManager.current_zone = self
		SoundManager.play_music(load(music_path))

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("Sortie de : ", zone_name)
