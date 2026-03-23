extends Node2D
class_name PuzzleVisualizer

@export var potion_scene : PackedScene
@export var chunk_scene : PackedScene
@export var color_list : ColorList
@export var camera : PuzzleCamera

@export var game_menu : PuzzleGameMenu
@export var background : Background

@export var audio_whoosh : AudioStreamPlayer2D
@export var audio_narrate : AudioStreamPlayer

@export var curve_jump : Curve

var potion_width := 256.0
var potions : Array[Potion] = []
var generator : PuzzleGenerator
var commands : Commands
var busy := false

var history_index := -1
var current_turn := 0

var jump_tween_active : Tween

func play_chunk_transfer_tween(from:PotionData, chunk:ChunkData, to:PotionData) -> void:
	if jump_tween_active:
		PuzzleTween.force_tween_completion(jump_tween_active)
	
	var pos1 := get_potion_for_data(from).get_position_of_top()
	var pos2 := get_potion_for_data(to).get_position_of_top()
	
	var distance_between := pos2.distance_to(pos1)
	var distance_factor := maxf(distance_between / 256.0, 1.0)
	var jump_height := 64.0 * distance_factor
	
	var mid_pos := 0.5 * (pos1 + pos2) + Vector2.UP * jump_height
	
	var new_chunk : Chunk = chunk_scene.instantiate()
	add_child(new_chunk)
	new_chunk.set_from_data(chunk)
	new_chunk.set_position(pos1)
	new_chunk.z_index = 1024
	
	audio_whoosh.set_position(pos1)
	audio_whoosh.play()
	
	var tw := get_tree().create_tween().set_trans(Tween.TRANS_LINEAR)
	var dur := randf_range(0.1, 0.15) * distance_factor
	
	var num_points_sampled := 10
	
	# we use a parabola curve to make the trajectory match it
	# the x position represents "time"; 
	# the curve's value at that time represents how close it is to the higher midpoint
	for i in range(num_points_sampled):
		var factor := (i+1.0) / num_points_sampled
		var x_pos := lerpf(pos1.x, pos2.x, factor)
		var y_pos_anchor := pos1.y if x_pos < mid_pos.x else pos2.y
		var y_pos := lerpf(y_pos_anchor, mid_pos.y, curve_jump.sample(factor))
		tw.tween_property(new_chunk, "position", Vector2(x_pos, y_pos), dur / num_points_sampled)
	jump_tween_active = tw
	
	await tw.finished
	new_chunk.queue_free()

func get_potion_for_data(d:PotionData) -> Potion:
	for potion in potions:
		if potion.data == d: return potion
	return null

func visualize(gen:PuzzleGenerator) -> void:
	generator = gen
	
	commands = Commands.new(self)
	add_child(commands)
	game_menu.commands = commands
	
	for potion in gen.potions:
		add_potion(potion)

	var num_turns := gen.count_turns()
	for i in range(num_turns):
		var target_color := get_target(i).data.color
		color_list.add_target_with_color(target_color)
	
	refresh()

	on_visualization_done()

func on_visualization_done() -> void:
	update_turn_number(0)
	PuzzleFramework.start_puzzle()

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
	level_size.y = maxf(level_size.y, 768.0) # ensure we don't zoom in TOO MUCH on tiny levels
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
	highlight_target()

func is_done() -> bool:
	return current_turn >= get_number_of_turns()

func get_current_turn() -> int:
	return clampi(current_turn, 0, generator.solution.size()-1)

func get_current_target() -> Potion:
	return get_target(get_current_turn())

func get_correct_potions() -> Array[Potion]:
	return potions.filter(func(p:Potion): return p.data.is_all_same_color())

func _on_potion_clicked(potion_clicked:Potion) -> void:
	if commands.is_busy() or busy: return
	
	var current_target := get_current_target()
	var invalid_move := potion_clicked.is_empty() or potion_clicked == current_target or current_target.is_full()
	if invalid_move:
		print("NOPE | Can't do that move.")
		potion_clicked.on_illegal_click()
		return
	
	busy = true
	potion_clicked.on_legal_click()
	
	commands.start_new_turn()
	var cmd := CommandTurn.new(potion_clicked.data, current_target.data)
	await commands.execute_command(cmd)
	commands.execute_command(CommandTurnEnd.new(self))
	
	# check for end of game (and whether we won or not)
	if is_done():
		var num_potions_correct := get_correct_potions().size()
		var all_potions_correct := num_potions_correct >= count_potions()
		await get_tree().create_timer(0.3).timeout
		busy = false
		PuzzleFramework.finish_puzzle(all_potions_correct)
		on_puzzle_finished()
		return
	
	busy = false

func on_puzzle_finished() -> void:
	for potion in potions:
		PuzzleTween.play_popdown_tween(potion)
	color_list.disappear()

func highlight_target() -> void:
	if is_done(): return
	
	for potion in potions:
		potion.set_focus(false)
	
	var cur_target := get_current_target()
	cur_target.set_focus(true)
	background.set_color(cur_target.data.color)
	
	color_list.highlight_target(get_current_turn())
	
	if PuzzleFramework.get_setting_value("narrate_colors"):
		audio_narrate.stream = load("res://map/chunks/sounds/" + ChunkData.convert_color_to_audio(cur_target.data.color) + ".ogg")
		audio_narrate.play()

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
