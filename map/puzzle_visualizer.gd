extends Node2D
class_name PuzzleVisualizer

@export var potion_scene : PackedScene
@export var chunk_scene : PackedScene

var potion_width := 64.0
var potions : Array[Potion] = []
var target_list : Array[Chunk]  = []
var generator : PuzzleGenerator

var history_index := -1
var current_turn := -1

func _input(ev:InputEvent) -> void:
	if ev.is_action_released("ui_left"):
		goto_puzzle_state(-1)
	if ev.is_action_released("ui_right"):
		goto_puzzle_state(+1)

func goto_puzzle_state(ds:int) -> void:
	history_index = clampi(history_index + ds, -1, generator.history.size() - 1)
	visualize(generator)

func visualize(gen:PuzzleGenerator) -> void:
	generator = gen
	
	destroy()
	
	var state_to_visualize := gen.history[mini(history_index, gen.history.size()-1)]
	for potion in state_to_visualize:
		add_potion(potion)

	var num_turns := gen.count_turns()
	for i in range(num_turns):
		var target := chunk_scene.instantiate()
		var target_color := get_target(i).data.color
		target.set_from_data(ChunkData.new(target_color))
		add_child(target)
		target_list.append(target)
	
	refresh()

	on_visualization_done()

func on_visualization_done() -> void:
	current_turn = 0
	highlight_target()

func destroy() -> void:
	for i in range(potions.size() -1, -1, -1):
		remove_potion(potions[i])
	for i in range(target_list.size() -1, -1, -1):
		remove_target(target_list[i])

func add_potion(potion:PotionData) -> void:
	var p : Potion = potion_scene.instantiate()
	p.set_from_data(potion)
	p.clicked.connect(_on_potion_clicked)
	add_child(p)
	potions.append(p)
	
	for chunk in potion.chunks:
		var c : Chunk = chunk_scene.instantiate()
		c.set_from_data(chunk)
		p.add_chunk(c)

func refresh() -> void:
	var num_potions := potions.size()
	var offset := -0.5 * (num_potions - 1) * potion_width * Vector2.RIGHT
	for i in range(num_potions):
		var pos := offset + i * potion_width * Vector2.RIGHT
		potions[i].set_position(pos)
	
	var num_targets := target_list.size()
	var target_width := 0.5 * potion_width
	var offset_targets := -0.5 * (num_targets - 1) * target_width * Vector2.RIGHT + Vector2.DOWN * potion_width
	for i in range(num_targets):
		var pos := offset_targets + i * target_width * Vector2.RIGHT
		target_list[i].set_position(pos)

func remove_potion(p:Potion) -> void:
	potions.erase(p)
	p.queue_free()

func remove_target(t:Chunk) -> void:
	target_list.erase(t)
	t.queue_free()

func get_target(idx:int) -> Potion:
	return potions[generator.solution[idx].to]

func get_current_target() -> Potion:
	return get_target(current_turn)

func _on_potion_clicked(p:Potion) -> void:
	var top_chunk := p.get_top_chunk()
	var current_target := get_current_target()
	
	p.remove_chunk(top_chunk)
	current_target.add_chunk(top_chunk)
	current_turn += 1
	highlight_target()

func highlight_target() -> void:
	for potion in potions:
		potion.set_scale(Vector2.ONE)
	get_current_target().set_scale(Vector2.ONE * 1.2)

#func _on_potion_clicked(p:Potion) -> void:
	#var chunks_to_add := p.chunks.duplicate(false)
	#
	## add it to all other potions + remove matches
	#for potion in potions:
		#if potion == p: continue
		#
		#for chunk in chunks_to_add:
			#var c : Chunk = chunk_scene.instantiate()
			#c.set_from_data(chunk.data)
			#potion.add_chunk(c)
		#
		#potion.reduce_by_matches()
	#
	## finally destroy the clicked potion for good
	#remove_potion(p)
