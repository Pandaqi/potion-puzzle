extends Node2D
class_name PotionSmall

@export var base : Sprite2D
@export var overlay : Sprite2D

var base_size := 256.0

func set_color(c:ChunkData.ColorName) -> void:
	overlay.modulate = ChunkData.convert_color_to_object(c)

func set_size(size:float) -> void:
	set_scale(size / base_size * Vector2.ONE)
