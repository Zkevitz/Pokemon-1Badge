extends Node2D

@export var ray_start: float = 150.0
@export var ray_end: float = 20.0
@export var duration: float = 1.5
@export var rounds: float = 2.0

var flames: Array
var running: bool
var time: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	running = false
	flames = [$Node/Flemme1, $Node/Flemme2, $Node/Flemme3, $Node/Flemme4]
	$Node/LePoing.visible = false
	for flame in flames:
		flame.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not running:
		return
	time += delta
	var t = clamp(time / duration, 0.0, 1.0)
	var ray = lerp(ray_start, ray_end, t)
	var angle_base = t*TAU*rounds
	for i in range(4):
		var angle = angle_base + (TAU / 4.0)*i
		flames[i].position = $Node/LePoing.position + Vector2(cos(angle), sin(angle)) * ray
	if t >= 0.9 and $Node/LePoing.visible == false:
		$Node/LePoing.visible = true
	if t >= 1.0:
		running = false



func play_attack(sender : PokemonNode, receiver : PokemonNode, battleui : BattleUI):
	time = 0.0
	$Node/LePoing.global_position = receiver.global_position
	for flame in flames:
		flame.visible = true
	running = true
	SoundManager.play_sfx(preload("res://sound/SFX/attack_sfx/FireSpin2.mp3"), -10)
	battleui.flash_screen(2, Color(1,0,0,0.0))
	await get_tree().create_timer(2).timeout

func setup_anim() ->void :
	pass
