extends CharacterBody2D
class_name NPC

@export_group("Visual")
@export var spriteFrame : SpriteFrames
@export var start_direction : Vector2 = Vector2.DOWN

@export_group("Position")
@export var start_position : Vector2 = Vector2(10, 10)
@export var Walkgrid : TileMapLayer

@onready var sprite := $AnimatedSprite2D
@onready var movement : NPCMovement = $MouvementComponent
@onready var behavior : NPCbehavior =
@onready var interaction : NPCinteract = $InteractComponent
@onready var trainer : TrainerComponent = $TrainerComponent if has_node("TrainerComponent") else null


func _ready() -> void:
	_setup_sprite()
	_setup_position()
	_setup_component()
	
func _setup_sprite():
	if spriteFrame :
		sprite.sprite_frames = spriteFrame

func _setup_position():
	if Walkgrid :
		global_position = Walkgrid.map_to_local(start_position)


func _setup_component():
	if movement:
		movement.initialize(sprite, start_direction)
	
	if behavior :
		behavior.initialize(movement)
	
	if interaction :
		interaction.initialize(movement)
		interaction.interaction_triggered.connect(_on_interaction_triggered)
	
	if trainer :
		trainer.initialize()
		trainer.battle_won.connect(_on_trainer_defeated)
		

func _on_interaction_triggered():
	if trainer and not trainer.is_defeated :
		await interaction.handle_trainer_encounter(interaction)
		
	elif interaction.has_dialogue : 
		await interaction.show_dialogue()

func _on_trainer_defeated() :
	if behavior :
		behavior.disable()
	
func stop():
	if behavior:
		behavior.pause()
	if movement :
		movement.stop()
		
func resume():
	if behavior :
		behavior.resume()
