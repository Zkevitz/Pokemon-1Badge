@tool
extends Sprite2D

func calculate_aspect_ratio():
	print("tool")
	material.set_shader_param("aspect_ratio", scale.y / scale.x) 
