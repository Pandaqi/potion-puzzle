extends CanvasLayer
class_name Background

@export var color_rect : ColorRect

func set_color(c:ChunkData.ColorName) -> void:
	var color_main := ChunkData.convert_color_to_object(c)
	# @TODO: blend lightened version with yellowish, darkened version with blueish?
	var color_tint_1 := color_main.lightened(0.2)
	var color_tint_2 := color_main.darkened(0.2)
	
	color_rect.material.set_shader_parameter("colour_1", color_main)
	color_rect.material.set_shader_parameter("colour_2", color_tint_1)
	color_rect.material.set_shader_parameter("colour_3", color_tint_2)
