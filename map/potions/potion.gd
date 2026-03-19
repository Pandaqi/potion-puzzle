extends Node2D
class_name Potion

var data : PotionData
var chunks : Array[Chunk] = []
var chunk_height := 32.0
var randomize_order := false

@export var vial : Sprite2D
@export var area : Area2D

signal clicked(p:Potion)

func _ready() -> void:
	area.input_event.connect(_on_input_event)

func _on_input_event(_vp:Node, ev:InputEvent, _shape_idx:int) -> void:
	if not ((ev is InputEventMouseButton) or (ev is InputEventScreenTouch)): return
	if not ev.is_released(): return
	clicked.emit(self)

func set_from_data(pd:PotionData) -> void:
	data = pd
	
	vial.modulate = ChunkData.convert_color_to_object(data.color)
	
	var base_height_vial := 128.0
	var desired_height := chunk_height * data.max_size
	vial.scale.y = desired_height / base_height_vial
	vial.position.y = -0.5 * desired_height

func add_chunk(c:Chunk) -> void:
	add_child(c)
	chunks.append(c)
	refresh()

func remove_chunk(c:Chunk) -> void:
	remove_child(c)
	chunks.erase(c)
	refresh()

func count() -> int:
	return chunks.size()

func get_top_chunk() -> Chunk:
	return chunks.back()

func refresh() -> void:
	var num_chunks := count()
	if randomize_order: chunks.shuffle()
	for i in range(num_chunks):
		var offset := (i+0.5) * chunk_height * Vector2.UP
		chunks[i].set_position(offset)

func reduce_by_matches() -> void:
	# first count how often each one exists
	var color_frequency : Dictionary[ChunkData.ColorName, int] = {}
	for chunk in chunks:
		var col := chunk.data.get_color()
		if not (col in color_frequency): color_frequency[col] = 0
		color_frequency[col] += 1
	
	# then remove the ones that are double
	# @TODO: very inefficient now with individual removals and stuff
	for i in range(chunks.size() - 1, -1, -1):
		var col := chunks[i].data.get_color()
		if color_frequency[col] <= 1: continue
		remove_chunk(chunks[i])
