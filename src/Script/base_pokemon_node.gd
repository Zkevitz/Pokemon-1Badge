extends Node2D
class_name PokemonNode

signal animation_finished
enum Type { AUCUN, NORMAL, FEU, EAU, PLANTE, ELECTRIQUE, GLACE, COMBAT, POISON, SOL, VOL,
	 PSY, INSECTE, ROCHE, SPECTRE, DRAGON, TENEBRES, ACIER, FEE}

@export_group("Comportements")
@export var is_wild : bool = true
@export var can_move : bool = false

var pokemonInstance : PokemonInstance

var animatedSprite : AnimatedSprite2D
var animation_player : AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if pokemonInstance.data.sprite_frames :
		animatedSprite.sprite_frames = pokemonInstance.data.sprite_frames
	animatedSprite.play("idle")
	
func setup(instance : PokemonInstance):
	pokemonInstance = instance
	animatedSprite = get_node("AnimatedSprite2D")
	animation_player = get_node("AnimationPlayer")
	if pokemonInstance.data.sprite_frames :
		animatedSprite.sprite_frames = pokemonInstance.data.sprite_frames
	animatedSprite.play("idle")

func sink_into_ground():
	print("sink into ground")
	var mat := animatedSprite.material
	var tween := create_tween()
	tween.tween_property(mat, "shader_parameter/sink_in_ground", 1.0, 0.8)
	await tween.finished
	animation_finished.emit()
	await get_tree().create_timer(1.5).timeout
	var info_panel = get_parent()
	queue_free()

func apply_status_in_Ui(status : String):
	var panel_info = get_parent().get_parent()
	print("info panel from apply _status ui :", panel_info)
	var text_label = panel_info.get_node("RichTextLabel")
	text_label.text = status
	text_label.visible = true
	
func Boost_stat_anim():
	var mat = animatedSprite.material
	var tween := create_tween()
	tween.tween_property(mat, "shader_parameter/boost_strength", 0.95 , 2.0)
	await tween.finished
	
	mat.set_shader_parameter("boost_strength", 0.0)
	animation_finished.emit()
	
func Drop_stat_anim():
	var mat = animatedSprite.material
	var tween := create_tween()
	tween.tween_property(mat, "shader_parameter/drop_strength", 0.95 , 2.0)
	await tween.finished
	
	mat.set_shader_parameter("drop_strength", 0.0)
	animation_finished.emit()
	
func flash_white():
	var mat = animatedSprite.material
	mat.set_shader_parameter("white_amount", 1.0)

	await get_tree().create_timer(0.08).timeout

	mat.set_shader_parameter("white_amount", 0.0)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
