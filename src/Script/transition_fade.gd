extends CanvasLayer

@onready var rect := $ColorRect
@onready var anim := $AnimationPlayer


signal fade_finished

func fade_in():
	anim.play("fade_in")
	
func fade_out():
	anim.play("fade_out")
	
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	emit_signal("fade_finished", anim_name)
