extends Node2D
class_name Chunk

var data : ChunkData

@export var sprite : Sprite2D

func set_from_data(cd:ChunkData) -> void:
	data = cd
	sprite.modulate = cd.get_color_as_object()
