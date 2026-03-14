extends Node2D
class_name PokemonNode

signal animation_finished
enum Type { AUCUN, NORMAL, FEU, EAU, PLANTE, ELECTRIQUE, GLACE, COMBAT, POISON, SOL, VOL,
	 PSY, INSECTE, ROCHE, SPECTRE, DRAGON, TENEBRES, ACIER, FEE}

@export_group("Comportements")
@export var is_wild : bool = true
@export var can_move : bool = false

var pokemonInstance : PokemonInstance
var is_opponent : bool = true
var animatedSprite : AnimatedSprite2D
var animation_player : AnimationPlayer
var scale_value : Vector2;
var original_modulate_color


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	original_modulate_color = modulate
	visible = false

func is_Opponent() -> bool :
	return is_opponent
	
func setup(instance : PokemonInstance):
	pokemonInstance = instance
	if pokemonInstance.is_wild == false :
		is_opponent = false
	animatedSprite = get_node("AnimatedSprite2D")
	animation_player = get_node("AnimationPlayer")
	if pokemonInstance.data.sprite_frames :
		animatedSprite.sprite_frames = pokemonInstance.data.sprite_frames
	animatedSprite.play("idle")

func sink_into_ground():
	var mat := animatedSprite.material
	var tween := create_tween()
	tween.tween_property(mat, "shader_parameter/sink_in_ground", 1.0, 0.9)
	await tween.finished
	animation_finished.emit()
	await get_tree().create_timer(1.5).timeout
	queue_free()

func fight_entry():
	visible = true
	scale = Vector2.ZERO
	
	flash_color(Color.WHITE, 1.1)
	var tween := create_tween()
	tween.tween_property(self, "scale", scale_value, 1.0)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
	await tween.finished

func fight_exit(need_to_free : bool = true):
	flash_color(Color.WHITE, 0.9)
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(0, 0), 0.8)
	SoundManager.play_sfx(preload("res://sound/SFX/battleSound/Battle recall.ogg"), -10)
	await tween.finished
	if need_to_free : 
		queue_free()
	
func apply_status_in_Ui(status : String):
	var panel_info = get_parent().get_parent()
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
	
func flash_color(color : Color, time : float):
	var mat = animatedSprite.material
	mat.set_shader_parameter("flash_color", color)
	mat.set_shader_parameter("flash_amount", 1.0)

	await get_tree().create_timer(time).timeout

	mat.set_shader_parameter("flash_amount", 0.0)
	
func vertical_shake():
	var mat = animatedSprite.material
	mat.set_shader_parameter("shake_vertical_amount", 0.5)
	
	await get_tree().create_timer(0.35).timeout
	mat.set_shader_parameter("shake_vertical_amount", 0.0)

func horizontal_ondulation(time : float):
	var mat = animatedSprite.material
	mat.set_shader_parameter("wave_strength", 0.005)
	
	await get_tree().create_timer(time).timeout
	mat.set_shader_parameter("wave_strength", 0.0)
	
func play_confusion():
	var confusion_anim = animatedSprite.get_node("ConfusionAnim")
	if confusion_anim : 
		confusion_anim.visible = true
		confusion_anim.play("default")
		SoundManager.play_sfx(preload("res://sound/SFX/status/Status Confused.mp3"), -10)
		await confusion_anim.animation_finished
		confusion_anim.visible = false

func play_para():
	var para_anim = animatedSprite.get_node("ParaAnim")
	if para_anim :
		para_anim.visible = true
		para_anim.play("default")
		SoundManager.play_sfx(preload("res://sound/SFX/status/Status Paralysis.ogg"), -10)
		await para_anim.animation_finished
		para_anim.visible = false
		
func play_sleep():
	animation_player.play("Sleep Anim")
	SoundManager.play_sfx(preload("res://sound/SFX/status/Status Sleep.mp3"), -10)
	await animation_player.animation_finished
	
func play_burn():
	var burn_node = preload("res://src/node/attack_anim/node/flammeche_anim.tscn").instantiate()
	
	var parent_node = get_parent()
	burn_node.setup_anim()
	parent_node.add_child(burn_node)
	await burn_node.play_burn(self)

func play_poison():
	var PoisonParticule = animatedSprite.get_node("GPUParticles2D")
	PoisonParticule.visible = true 
	
	horizontal_ondulation(1.0)
	await flash_color(Color(0.478, 0.0, 1.0), 1.0)
	
	PoisonParticule.visible = false

func play_heal_up_anim():
	var mat := animatedSprite.material
	
	mat.set_shader_parameter("heal_strength", 1.0)
	animation_player.play("heal_up")
	SoundManager.play_sfx(preload("res://sound/SFX/status/In-Battle Heal HP Restore.mp3"), -15)
	
	await get_tree().create_timer(1.6).timeout
	mat.set_shader_parameter("heal_strength", 0.0)
	await  animation_player.animation_finished
	
func make_attack_move(attack_dir : int):
	var tween = create_tween()
	tween.tween_property(self, "position:x", self.position.x + attack_dir, 0.1)
	tween.tween_property(self, "position:x", self.position.x, 0.1)
	await tween.finished
