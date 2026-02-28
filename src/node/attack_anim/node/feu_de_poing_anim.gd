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
	running = true
	flames = [$Node/Flemme1, $Node/Flemme2, $Node/Flemme3, $Node/Flemme4]

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
		print("Flamme %d pos: " % i)
		print(flames[i].position)
	if t >= 1.0:
		running = false


func play_attack(sender : PokemonNode, receiver : PokemonNode, battleui : BattleUI):
	time = 0.0
	running = true

func setup_anim() ->void :
	pass
