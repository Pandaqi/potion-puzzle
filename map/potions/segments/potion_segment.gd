extends Node2D
class_name PotionSegment

@export var base : Sprite2D
@export var center : Sprite2D
@export var overlay : Sprite2D
var active := false
var chunk : Chunk

enum Type
{
	TOP,
	MIDDLE,
	BOTTOM
}

var type_to_frame : Dictionary[Type, int] = {
	Type.TOP: 0,
	Type.MIDDLE: 1,
	Type.BOTTOM: 2,
}

var type : Type

func set_active(ac:bool) -> void:
	active = ac
	set_visible(ac)

func set_type(tp:Type) -> void:
	type = tp
	
	var frame := type_to_frame[type]
	base.set_frame(frame)
	center.set_frame(frame)
	overlay.set_frame(frame)

func set_color(col:ChunkData.ColorName) -> void:
	base.modulate = ChunkData.convert_color_to_object(col)

func get_size() -> Vector2:
	return Vector2(256, 176)

func has_chunk() -> bool:
	return chunk != null

func link_chunk(c:Chunk) -> void:
	if has_chunk():
		print("Error! Already have a chunk!")
		return
	
	chunk = c
	add_child(c)
	c.set_position(Vector2.ZERO)
	chunk.z_index = 20 # 0 = base, 10 = center, 30 = overlay

func unlink_chunk() -> void:
	if not has_chunk(): 
		print("Error! No chunk to unlink!")
		return
	
	remove_child(chunk)
	chunk = null
