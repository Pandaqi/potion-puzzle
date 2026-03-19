class_name PuzzleGeneratorMatchAnywhere

## Number of potions to work towards
var num_potion_bounds := Vector2i(4, 6)

## Maximum size of potions before they overflow
var potion_size_bounds := Vector2i(3, 4)
var potion_size := -1

var make_shared_cutoff_probability := 0.2
var add_unused_cutoff_probability := 0.2
var pick_shared_cutoff_probability := 0.2

## The [min,max] number of chunks with which the first potion starts
var potion_start_contents_bounds := Vector2i(2,4)

## Exact final configuration of potions + chunks presented to player as puzzle
var potions : Array[PotionData]

## Solution found by generator => which potion to tap on each turn (by starting index)
var solution : Array[int]

## History of steps by generator, used for debugging
var history : Array[Array]

func generate() -> void:
	create_random_setup()
	take_turns()

func create_random_setup() -> void:
	potion_size = randi_range(potion_size_bounds.x, potion_size_bounds.y)
	
	var starting_potion := PotionData.new(potion_size)
	potions.append(starting_potion)
	
	var num_chunks_start := randi_range(potion_start_contents_bounds.x, potion_start_contents_bounds.y)
	var all_colors := ChunkData.get_all_colors()
	all_colors.shuffle()
	for a in range(num_chunks_start):
		starting_potion.add_chunk(ChunkData.new(all_colors.pop_back()))

func get_used_colors() -> Array[ChunkData.ColorName]:
	var used_colors := ChunkData.get_all_colors()
	var unused_colors := get_unused_colors()
	for color in unused_colors:
		used_colors.erase(color)
	return used_colors

func get_unused_colors() -> Array[ChunkData.ColorName]:
	var unused_colors := ChunkData.get_all_colors()
	for potion in potions:
		for color in potion.get_colors():
			unused_colors.erase(color)
	return unused_colors

func get_unshared_colors() -> Array[ChunkData.ColorName]:
	# if only a single potion, nothing can be shared between potions of course!
	if potions.size() <= 1: return []
	
	var shared_colors := get_shared_colors()
	var used_colors := get_used_colors()
	for color in shared_colors:
		used_colors.erase(color)
	return used_colors

func get_shared_colors() -> Array[ChunkData.ColorName]:
	var colors_present : Dictionary[ChunkData.ColorName, Array] = {}
	
	# create dictionary of which potions a color appears in
	for potion in potions:
		for color in potion.get_colors():
			if not (color in colors_present): colors_present[color] = []
			if colors_present[color].has(potion): continue # already counted this one
			colors_present[color].append(potion)
	
	# then find the ones where this list contains ALL potions
	return colors_present.keys().filter(func(c:ChunkData.ColorName): return colors_present[c].size() >= potions.size())

func potions_have_space_for(dc:int) -> bool:
	for potion in potions:
		if potion.get_space_available() < dc:
			return false
	return true

func save_state_to_history() -> void:
	var state : Array[PotionData] = []
	for potion in potions:
		state.append(potion.clone())
	history.append(state)

func take_turns() -> void:
	var num_potions_total := randi_range(num_potion_bounds.x, num_potion_bounds.y)
	solution = []
	history = []
	save_state_to_history()
	
	while potions.size() < num_potions_total:
		# start a new potion; we'll fill it with the right stuff as we go
		var new_potion := PotionData.new(potion_size)
		
		# find any shared colors
		var shared_colors := get_shared_colors()
		shared_colors.shuffle()
		while shared_colors.size() > 0 and (not new_potion.is_full()):
			var stop_early := randf() <= pick_shared_cutoff_probability and (not new_potion.is_empty())
			if stop_early: break
			
			new_potion.add_chunk(ChunkData.new(shared_colors.pop_back()))
		
		# if we have unused colors, add them double to all potions
		# this means that, if we just give 1 to the new potion, they will cancel out upon mix
		var unused_colors := get_unused_colors()
		unused_colors.shuffle()
		while unused_colors.size() > 0 and (not new_potion.is_full()) and potions_have_space_for(1):
			var stop_early := randf() <= add_unused_cutoff_probability and (not new_potion.is_empty())
			if stop_early: break
			
			var new_chunk := ChunkData.new(unused_colors.pop_back())
			new_potion.add_chunk(new_chunk)
			for potion in potions:
				potion.add_chunk(new_chunk)
				potion.add_chunk(new_chunk)
		
		# if still not happy, pick a color in a random potion that is NOT shared by all
		# Add this to all other potions + the new potion
		var unshared_colors := get_unshared_colors()
		unshared_colors.shuffle()
		while unshared_colors.size() > 0 and (not new_potion.is_full()):
			var stop_early := randf() <= make_shared_cutoff_probability and (not new_potion.is_empty())
			if stop_early: break
			
			var color_to_share : ChunkData.ColorName = unshared_colors.pop_back()
			var potions_missing_it : Array[PotionData] = potions.filter(func(p:PotionData): return not p.has_color(color_to_share))

			if potions_missing_it.size() <= 0: continue
			
			var cant_use := false
			for potion in potions_missing_it:
				if potion.is_full(): 
					cant_use = true
					break
			
			if cant_use: continue
			
			var new_chunk := ChunkData.new(color_to_share)
			new_potion.add_chunk(new_chunk)
			for potion in potions_missing_it:
				potion.add_chunk(new_chunk)
				potion.add_chunk(new_chunk)
		
		# finally, execute this new thing
		# split this new potion off of the existing ones
		for potion in potions:
			potion.remove_colors(new_potion.get_colors())
		potions.append(new_potion)
		
		solution.append(potions.size() - 1)
		save_state_to_history()
