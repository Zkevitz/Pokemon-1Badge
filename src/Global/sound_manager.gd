extends Node


var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer
var ui_player: AudioStreamPlayer

var volume_value := 0.0

const foot_step_sound = {
	"dirt" : [
		preload("res://sound/SFX/footStep/dirt_1.wav"),
		preload("res://sound/SFX/footStep/dirt_2.wav"),
		preload("res://sound/SFX/footStep/dirt_3.wav")
	]
}
func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)

	# SFX
	sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = "SFX"
	add_child(sfx_player)

	# UI
	ui_player = AudioStreamPlayer.new()
	ui_player.bus = "UI"
	add_child(ui_player)
	
	music_player.finished.connect(on_music_finised)

func on_music_finised():
	music_player.play()

#UTILISATION : AudioManager.play_music(preload("res://music/route_201.ogg"))
func play_music(stream : AudioStream, fade := true) :
	if (music_player.stream == stream) :
		return
	if music_player.playing :
		if fade :
			await fade_out_music()
		else :
			music_player.stop()
	music_player.stream = stream
	music_player.volume_db = -35
	music_player.play()

#UTILISATION : AudioManager.play_sfx(preload("res://sfx/step.wav"))
func play_sfx(stream : AudioStream, volume : int):
	var p := AudioStreamPlayer.new()
	p.stream = stream
	p.bus = "SFX"
	p.volume_db = volume
	add_child(p)
	p.play()
	p.finished.connect(p.queue_free)

#UTILISATION : AudioManager.play_ui(preload("res://ui/click.wav"))
func play_ui(Stream : AudioStream) :
	ui_player.stream = Stream
	ui_player.play()
	
func fade_out_music(time := 0.5):
	var tween = create_tween()
	tween.tween_property(music_player, "volume_db", -40, time)
	await tween.finished
	music_player.stop()

func play_foot_step(_position : Vector2):
	var random_dirt_sound = foot_step_sound["dirt"].pick_random()
	play_sfx(random_dirt_sound, -22)

func set_master_vulume(db : float):
	var bus := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus, db)
	volume_value = db
	
func set_sfx_volume(db: float):
	var bus := AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(bus, db)

func set_music_volume(db: float):
	var bus := AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(bus, db)

func set_ui_volume(db: float):
	var bus := AudioServer.get_bus_index("UI")
	AudioServer.set_bus_volume_db(bus, db)
	
