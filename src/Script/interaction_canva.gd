extends CanvasLayer

@onready var panel = $Control/PanelContainer
@onready var label = $Control/PanelContainer/Label
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	panel.visible = false


func show_prompt(text : String = "Appuyer sur [E] pour parler"):
	label.text = text
	panel.visible = true

func hide_prompt():
	panel.visible = false

func _process(delta: float) -> void:
	pass
