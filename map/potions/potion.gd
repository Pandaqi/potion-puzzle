extends Node2D
class_name Potion

var data : PotionData
var size : Vector2
var hovering := false
var is_current_target := false
var was_full := false

var segments : Array[PotionSegment] = []
@export var segment_scene : PackedScene
@export var segment_container : Node2D
@export var anim_player : AnimationPlayer
@export var smiley : Sprite2D
@export var shape : Sprite2D

@export var cork_container : Node2D
@export var cork : Sprite2D

@export var area : Area2D
@export var area_shape : CollisionShape2D

@export var audio_error : AudioStreamPlayer2D
@export var audio_click : AudioStreamPlayer2D

signal clicked(p:Potion)

func _ready() -> void:
	area.input_event.connect(_on_input_event)
	area.mouse_entered.connect(_on_mouse_entered)
	area.mouse_exited.connect(_on_mouse_exited)
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
	return size

func on_illegal_click() -> void:
	PuzzleAudio.play_audio_nice(audio_error)
	PuzzleTween.play_wiggle_tween(self)

func on_legal_click() -> void:
	PuzzleAudio.play_audio_nice(audio_click)

func _process(dt:float) -> void:
	animate_hover(dt)

func animate_hover(dt:float) -> void:
	if is_current_target: return
	
	var target_y := -12.0 if hovering else 0.0
	var target_modulate := Color(1.15, 1.15, 1.15) if hovering else Color.WHITE
	var target_y_cork := -96.0 if hovering else 0.0
	self.modulate = modulate.lerp(target_modulate, 8*dt)
	self.position.y = lerpf(position.y, target_y, 8*dt)
	cork.position.y = lerpf(cork.position.y, target_y_cork, 8*dt)

func _on_mouse_entered() -> void:
	hovering = true

func _on_mouse_exited() -> void:
	hovering = false

func set_focus(fc:bool) -> void:
	is_current_target = fc
	if PuzzleFramework.get_setting_value("wiggle_target") != true: return
	if not fc: anim_player.stop(false)
	else: anim_player.play("highlighted")

func count() -> int:
	return data.count()

func is_empty() -> bool:
	return count() <= 0

func is_full() -> bool:
	return count() >= data.max_size

func get_position_of_top() -> Vector2:
	return global_position + Vector2(0, -size.y)

func refresh() -> void:
	
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
		
		# link to the chunks in our data
		segment.unlink_chunk()
		if type == PotionSegment.Type.MIDDLE and (i-1) < count():
			var linked_chunk := data.chunks[i-1]
			segment.link_chunk(self, linked_chunk)
	
	# make smiley reflect if potion is finished
	smiley.set_frame(0 if data.is_all_same_color() else 1)
	
	# resize area to match height
	var total_height := absf(highest_segment_position.y)
	size = Vector2(max_segment_width, total_height)
	
	area_shape.position.y = -0.5*total_height
	area_shape.shape.size = size
	
	# display shape hint if playing that mode
	shape.hide()
	if PuzzleVisualizer.uses_shapes():
		shape.show()
		shape.set_frame(ChunkData.convert_shape_to_frame(ChunkData.convert_color_to_shape(data.color)))
		shape.set_position(to_local(get_position_of_top()) + Vector2.DOWN*50.0)
	
	# display cork if we're full
	var should_show_cork : bool = PuzzleFramework.get_setting_value("show_cork")
	cork_container.set_visible(should_show_cork)
	if should_show_cork:
		if data.is_full() and not was_full:
			var tw := get_tree().create_tween()
			tw.tween_property(cork_container, "modulate:a", 1.0, 0.2)
			cork_container.set_position(to_local(get_position_of_top()) + Vector2.DOWN*30.0)
		else:
			var tw := get_tree().create_tween()
			tw.tween_property(cork_container, "modulate:a", 0.0, 0.2)
	
	was_full = data.is_full()


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
