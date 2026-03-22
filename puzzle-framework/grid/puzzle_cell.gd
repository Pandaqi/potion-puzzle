extends RefCounted
class_name PuzzleCell

var pos : Vector2i

signal changed()

func _init(p:Vector2i) -> void:
	pos = p
