extends CanvasLayer

@onready var rect := $ColorRect
@onready var anim := $AnimationPlayer


signal fade_finished

func fade_in():
	print("layer is number in : ", layer)
	anim.play("fade_in")
	
func fade_out():
	anim.play_backwards("fade_in")
	print("layer is number out : ", layer)
	


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	emit_signal("fade_finished", anim_name)
