class_name PuzzleGeneratorConstraints

## Number of potions the puzzle starts with
var num_potion_bounds := Vector2i(4,6)

## Maximum size of potions before they overflow
var potion_size_bounds := Vector2i(8,10)

## The [min,max] of the number of chunks with which a potion starts
var potion_start_contents_bounds := Vector2i(1,3)

## Likelihood of saying chunks are "equal" and will remove even if not strictly necessary
var reduce_size_random_probability := 0.0

## Exact configuration of potions + contents that determine the puzzle presented to the player
var potions_start : Array[PotionData]

## Solution found by generator => which potion to tap on each turn (by starting index)
var solution : Array[int]

func generate() -> void:
	solution = []
	
	create_random_setup()
	var potions := take_turns()
	solve_constraints()

func create_random_setup() -> void:
	var num_potions := randi_range(num_potion_bounds.x, num_potion_bounds.y)
	var potion_size := randi_range(potion_size_bounds.x, potion_size_bounds.y)
	
	potions_start = []
	for i in range(num_potions):
		var p := PotionData.new(potion_size)
		potions_start.append(p)
		
		var num_chunks_start := randi_range(potion_start_contents_bounds.x, potion_start_contents_bounds.y)
		for a in range(num_chunks_start):
			p.add_chunk(ChunkData.new())

func should_reduce_potion(p:PotionData) -> bool:
	var has_overflowed := p.has_overflowed()
	var reduce_size_random := randf() <= reduce_size_random_probability
	return has_overflowed or reduce_size_random

func take_turns() -> Array[PotionData]:
	# clone all potions so we don't modify the original puzzle
	# (but the ChunkData remains shared/reference, as that's what we're actually generating and deciding here)
	var potions : Array[PotionData] = []
	for i in range(potions_start.size()):
		var potion_cloned := potions_start[i].clone()
		potion_cloned.index = i
		potions.append(potion_cloned)
	potions.shuffle()
	
	# while potions left, pick one to add to all others
	while potions.size() > 1:
		var rand_potion : PotionData = potions.pop_back()
		var contents := rand_potion.chunks
		solution.append(rand_potion.index)
		
		# shortcut, nothing needs to happen
		if contents.size() <= 0: continue

		for other_potion in potions:
			var old_size := other_potion.count()
			other_potion.add_chunks(contents)
			
			# while we've overflowed
			# make the next pair of chunks equal so we don't (they are removed)
			var reduction_index := old_size - 1
			var nothing_more_to_check := false
			while should_reduce_potion(other_potion):
				var c1 := other_potion.get_chunk_at(reduction_index)
				var c2 := other_potion.get_chunk_at(reduction_index + 1)
				
				c1.add_constraint_equal(c2)
				other_potion.remove_chunk(c1)
				other_potion.remove_chunk(c2)
				
				reduction_index -= 1
				
				nothing_more_to_check = reduction_index > other_potion.count() - 2
				if nothing_more_to_check: break
			
			# now we have our final state, which requires the two chunks touching are DIFFERENT
			if not nothing_more_to_check:
				var c1 := other_potion.get_chunk_at(reduction_index)
				var c2 := other_potion.get_chunk_at(reduction_index + 1)
				c1.add_constraint_unequal(c2)
	
	return potions

## A loop to find all chunks that should be equal to one another
## (If a chunk already exists in the list, we DON'T mark it to be checked again, or it would recurse endlessly)
func get_all_chunks_with_constraint(target:ChunkData, unequal := false) -> Array[ChunkData]:
	var chunks_to_examine : Array[ChunkData] = [target]
	var chunks_found : Array[ChunkData] = []
	while chunks_to_examine.size() > 0:
		var c : ChunkData = chunks_to_examine.pop_back()
		chunks_found.append(c)
		
		var options := c.constraints_unequal if unequal else c.constraints_equal
		for other_chunk in options:
			if chunks_found.has(other_chunk) or chunks_to_examine.has(other_chunk): continue
			chunks_to_examine.append(other_chunk)
	
	return chunks_found

func get_all_chunks() -> Array[ChunkData]:
	var arr : Array[ChunkData] = []
	for potion in potions_start:
		arr += potion.chunks
	return arr

func solve_constraints() -> void:
	# first get all unique chunks as a flat list, which leads to much cleaner code later
	var chunks := get_all_chunks()
	
	# find all chunks that should be equal, assign them some colors
	var constraint_colors := ChunkData.get_all_colors()
	constraint_colors.shuffle()
	for chunk_to_examine in chunks:
		if chunk_to_examine.is_final(): continue
		
		var equal_chunks := get_all_chunks_with_constraint(chunk_to_examine, false)
		if equal_chunks.size() <= 1: continue # only equal with ourselves
		
		var color : ChunkData.ColorName = constraint_colors.pop_back()
		for chunk in equal_chunks:
			chunk.set_color(color)
	
	# now find all chunks that should be unequal
	# (this does not "check" validity after the fact)
	for chunk_to_examine in chunks:
		var unequal_chunks := get_all_chunks_with_constraint(chunk_to_examine, true)
		unequal_chunks.erase(chunk_to_examine)
		
		var colors_allowed := ChunkData.get_all_colors()
		colors_allowed.shuffle()
		var already_assigned := chunk_to_examine.is_final()
		
		# if we already have a color, then just disallow ours and assign the others randomly
		if already_assigned:
			colors_allowed.erase(chunk_to_examine.get_color())
			for chunk in unequal_chunks:
				if chunk.is_final(): continue
				chunk.set_color(colors_allowed.pop_back())
		
		# otherwise, check what colors the others already have, disallow that, pick random from remaining colors
		if not already_assigned:
			for chunk in unequal_chunks:
				if not chunk.is_final(): continue
				colors_allowed.erase(chunk.get_color())
			chunk_to_examine.set_color(colors_allowed.pick_random())
			
	# go through all remaining chunks and color them randomly, as long as it's different from neighbors
	for potion in potions_start:
		for chunk_to_examine in potion.chunks:
			if chunk_to_examine.is_final(): continue

			var colors_allowed := ChunkData.get_all_colors()
			var nbs := potion.get_neighbor_chunks(chunk_to_examine)
			for nb in nbs:
				if not nb.is_final(): continue
				colors_allowed.erase(nb.color)
			
			chunk_to_examine.set_color(colors_allowed.pick_random())
	
