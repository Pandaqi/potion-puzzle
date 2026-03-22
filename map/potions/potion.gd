extends Node2D
class_name Potion

var data : PotionData

var segments : Array[PotionSegment] = []
@export var segment_scene : PackedScene
@export var segment_container : Node2D
@export var anim_player : AnimationPlayer

@export var area : Area2D
@export var area_shape : CollisionShape2D

@export var audio_error : AudioStreamPlayer2D

signal clicked(p:Potion)

func _ready() -> void:
	area.input_event.connect(_on_input_event)
	area_shape.shape = RectangleShape2D.new()

func _on_input_event(_vp:Node, ev:InputEvent, _shape_idx:int) -> void:
	if not ((ev is InputEventMouseButton) or (ev is InputEventScreenTouch)): return
	if not ev.is_released(): return
	clicked.emit(self)

func set_from_data(pd:PotionData) -> void:
	data = pd
	data.changed.connect(refresh)
	refresh()

func get_size() -> Vector2:
	return area_shape.shape.size

func on_illegal_click() -> void:
	PuzzleAudio.play_audio_nice(audio_error)
	PuzzleTween.play_wiggle_tween(self)

func set_focus(fc:bool) -> void:
	if not fc: anim_player.stop(false)
	else: anim_player.play("highlighted")

func is_empty() -> bool:
	return data.count() <= 0

func is_full() -> bool:
	return data.count() >= data.max_size

func is_all_same_color() -> bool:
	if count() <= 1: return true
	
	var first_color : ChunkData.ColorName = chunks.front().data.color
	for i in range(1, count()):
		if chunks[i].data.color != first_color: return false
	return true

func refresh() -> void:
	var num_chunks := data.count()
	
	# add potion segments as needed
	var max_potion_size := data.max_size
	var segments_needed := max_potion_size + 2
	while segments.size() < segments_needed:
		var s := segment_scene.instantiate()
		segment_container.add_child(s)
		segments.append(s)
	
	# make sure all chunks are free to re-shuffle
	for segment in segments:
		if segment.has_chunk(): 
			segment.unlink_chunk()
	
	# turn each segment into the right thing
	var num_segments := segments.size()
	var highest_segment_position := Vector2.ZERO
	var max_segment_width := 0.0
	for i in range(num_segments):
		var segment := segments[i]
		
		# we may have more segments than potion size, so just hide/disable the superfluous ones
		var is_used := i < segments_needed
		segment.set_active(is_used)
		if not is_used: continue
		
		segment.set_color(data.color)
		
		# Top/Middle/Bottom parts
		var type := PotionSegment.Type.MIDDLE
		if i == 0: type = PotionSegment.Type.BOTTOM
		if i == (num_segments - 1): type = PotionSegment.Type.TOP
		segment.set_type(type)
		
		# proper position
		var segment_size := segment.get_size()
		max_segment_width = maxf(max_segment_width, segment_size.x)
		var pos := i * segment_size.y * Vector2.UP
		highest_segment_position = pos
		segment.set_position(pos)
		
		# @TODO: rewrite to just enabling/disabling/recoloring chunks already within the segment
		# insert chunks as needed
		if type == PotionSegment.Type.MIDDLE and (i-1) < num_chunks:
			segment.link_chunk(chunks[i - 1])
	
	# resize area to match height
	var total_height := absf(highest_segment_position.y)
	area_shape.position.y = -0.5*total_height
	area_shape.shape.size = Vector2(max_segment_width, total_height)

#func reduce_by_matches() -> void:
	## first count how often each one exists
	#var color_frequency : Dictionary[ChunkData.ColorName, int] = {}
	#for chunk in chunks:
		#var col := chunk.data.get_color()
		#if not (col in color_frequency): color_frequency[col] = 0
		#color_frequency[col] += 1
	#
	## then remove the ones that are double
	## @TODO: very inefficient now with individual removals and stuff
	#for i in range(chunks.size() - 1, -1, -1):
		#var col := chunks[i].data.get_color()
		#if color_frequency[col] <= 1: continue
		#remove_chunk(chunks[i])
