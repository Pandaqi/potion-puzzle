extends Node2D
class_name PuzzleVisualizer

@export var potion_scene : PackedScene
@export var chunk_scene : PackedScene
@export var color_list : ColorList
@export var camera : PuzzleCamera

@export var audio_error : AudioStreamPlayer2D

var potion_width := 256.0
var potions : Array[Potion] = []
var generator : PuzzleGenerator
var commands : PuzzleCommands

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
	
	commands = PuzzleCommands.new()
	add_child(commands)
	
	destroy()
	
	var state_to_visualize := gen.history[mini(history_index, gen.history.size()-1)]
	for potion in state_to_visualize:
		add_potion(potion)

	var num_turns := gen.count_turns()
	for i in range(num_turns):
		var target_color := get_target(i).data.color
		color_list.add_target_with_color(target_color)
	
	refresh()

	on_visualization_done()

func on_visualization_done() -> void:
	current_turn = 0
	highlight_target()
	PuzzleFramework.start_puzzle()

func destroy() -> void:
	for i in range(potions.size() -1, -1, -1):
		remove_potion(potions[i])
	color_list.destroy()

func add_potion(potion:PotionData) -> void:
	var p : Potion = potion_scene.instantiate()
	p.clicked.connect(_on_potion_clicked)
	add_child(p)
	potions.append(p)
	
	p.set_from_data(potion)

func refresh() -> void:
	var num_potions := potions.size()
	var offset := -0.5 * (num_potions - 1) * potion_width * Vector2.RIGHT
	var max_potion_size := Vector2.ZERO
	for i in range(num_potions):
		var size := potions[i].get_size()
		max_potion_size.x = maxf(size.x, max_potion_size.x)
		max_potion_size.y = maxf(size.y, max_potion_size.y)
		var pos := offset + i * potion_width * Vector2.RIGHT
		potions[i].set_position(pos)
	
	var level_size := Vector2(max_potion_size.x * num_potions, max_potion_size.y)
	var level_bounds := Rect2(Vector2(-0.5*level_size.x, -level_size.y), level_size)
	camera.target = level_bounds

func remove_potion(p:Potion) -> void:
	potions.erase(p)
	p.queue_free()

func get_number_of_turns() -> int:
	return generator.solution.size()

func get_target(idx:int) -> Potion:
	return potions[generator.solution[idx].to]

func count_potions() -> int:
	return potions.size()

func update_turn_number(dt:int) -> void:
	current_turn += dt

func get_current_target() -> Potion:
	return get_target(current_turn)

func get_correct_potions() -> Array[Potion]:
	return potions.filter(func(p:Potion): return p.is_all_same_color())

func _on_potion_clicked(potion_clicked:Potion) -> void:
	var current_target := get_current_target()
	var invalid_move := potion_clicked.is_empty() or potion_clicked == current_target or current_target.is_full()
	if invalid_move:
		print("NOPE | Can't do that move.")
		potion_clicked.on_illegal_click()
		return
	
	commands.start_new_turn()

	var cmd := CommandTurn.new(potion_clicked.data, current_target.data)
	commands.execute_command(cmd)
	commands.execute_command(CommandTurnEnd.new(self))
	
	# @TODO: Update Potion to listen to changes in PotionData and automatically update chunks inside
	# => Probably more efficient to just have a chunk inside each PotionSegment by default and turn that on/off, right?
	#p.remove_chunk(top_chunk)
	#current_target.add_chunk(top_chunk)
	
	# check for end of game (and whether we won or not)
	var is_last_turn := current_turn >= get_number_of_turns()
	if is_last_turn:
		var num_potions_correct := get_correct_potions().size()
		var all_potions_correct := num_potions_correct >= count_potions()
		PuzzleFramework.finish_puzzle(all_potions_correct)
		return
	
	highlight_target()

func highlight_target() -> void:
	for potion in potions:
		potion.set_focus(false)
	get_current_target().set_focus(true)

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
