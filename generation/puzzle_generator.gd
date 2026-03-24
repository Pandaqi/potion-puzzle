class_name PuzzleGenerator

## Number of potions to work towards
var num_potion_bounds := Vector2i(4, 6)

## Maximum size of potions before they overflow
var potion_size_bounds := Vector2i(3, 4)

## If not allowed, it just picks one number (within size bounds) and uses that for all potions
var allow_different_potion_sizes := false

## The [min,max] number of chunks with which every potion starts
var potion_start_contents_bounds := Vector2i(2,4)

## The number of moves the final puzzle solution should have
var num_moves_bounds := Vector2i(3, 7)

## This prefers picking from the same potion multiple times in a row to make it emptier
## (Instead of mostly reshuffling stuff at the top)
var prefer_deep_grab_probability := 0.33

## We calculate a ratio of "wrong_chunks" / "all_chunks" and it must be higher than this number
## Otherwise the puzzle does not have a varied enough start state
var initial_state_diversity_factor := 0.2

## If turned on, the generator does not allow itself to visit states multiple times
## (Which usually means repeating itself and part of the solution being "useless"
var forbid_repetitive_states := true

## How many times we retry before we loosen our restrictions such that we likely find something in one go
var max_attempts := 1000

## Exact final configuration of potions + chunks presented to player as puzzle
var potions : Array[PotionData]

## Solution found by generator => { from: start_potion, to: target_potion }
var solution : Array[Dictionary]

func generate() -> void:
	PuzzleFramework.apply_difficulty_settings(self)
	var counter := 0
	while true:
		print("PuzzleGenerator | Attempt " + str(counter))
		counter += 1
		
		create_random_setup()
		take_turns(counter)
		var is_valid := clean_up(counter)
		if is_valid: break

func create_random_setup() -> void:
	var num_potions := randi_range(num_potion_bounds.x, num_potion_bounds.y)
	var potion_size_global := randi_range(potion_size_bounds.x, potion_size_bounds.y)
	
	var all_colors := ChunkData.get_all_colors()
	all_colors.shuffle()
	
	# we have fewer shapes than colors, remove the least interesting ones
	if PuzzleVisualizer.uses_shapes():
		all_colors.erase(ChunkData.ColorName.BROWN)
		all_colors.erase(ChunkData.ColorName.GRAY)
		all_colors.erase(ChunkData.ColorName.WHITE)
	
	potions = []
	var potions_at_max_size := 0
	for i in range(num_potions):
		var potion_size := randi_range(potion_size_bounds.x, potion_size_bounds.y)
		if not allow_different_potion_sizes: potion_size = potion_size_global
		
		var p := PotionData.new(potion_size)
		potions.append(p)
		
		var color_chosen : ChunkData.ColorName = all_colors.pop_back()
		p.color = color_chosen
	
		var num_chunks_start := randi_range(potion_start_contents_bounds.x, mini(potion_size, potion_start_contents_bounds.y))
		
		# prevent ALL potions from being at max size at start, which leaves no room for moving stuff
		if num_chunks_start >= potion_size: 
			potions_at_max_size += 1
		if potions_at_max_size > 0.33*num_potions: 
			num_chunks_start = mini(num_chunks_start, potion_size - 1)
		
		for a in range(num_chunks_start):
			p.add_chunk(ChunkData.new(color_chosen))

func get_random_potion_not_full(exclude : Array[PotionData] = []) -> PotionData:
	var potions_not_full := potions.filter(func(p:PotionData): return not p.is_full() and not exclude.has(p))
	if potions_not_full.size() <= 0: return null
	return potions_not_full.pick_random()

func get_random_potion_with_content(exclude : Array[PotionData] = []) -> PotionData:
	var potions_with_content := potions.filter(func(p:PotionData): return not p.is_empty() and not exclude.has(p))
	if potions_with_content.size() <= 0: return null
	return potions_with_content.pick_random()

func get_state_hash() -> String:
	var hs := ""
	for potion in potions:
		hs += potion.get_hash()
	return hs

func take_turns(num_attempts : int) -> void:
	solution = []

	var commands := Commands.new()
	commands.generating = true
	
	var num_steps := randi_range(num_moves_bounds.x, num_moves_bounds.y)
	var state_hashes : Array[String] = [get_state_hash()]
	var last_move : Dictionary = {}
	for i in range(num_steps):
		# pick random potion to bring something TO
		var start_potion := get_random_potion_not_full([])
		
		# with some chance, prefer reusing the same potion several times in a row to make it emptier
		if randf() <= prefer_deep_grab_probability:
			if not last_move.is_empty() and not potions[last_move.from].is_full():
				start_potion = potions[last_move.from]
		
		if not start_potion: break
		
		# pick random potion to take something OUT OF
		var target_potion := get_random_potion_with_content([start_potion])
		if not target_potion: break
		
		# forbid simply undoing our last move (exact same thing but from/to reversed)
		if not last_move.is_empty():
			var is_inverse_of_last_move : bool = potions[last_move.from] == target_potion and potions[last_move.to] == start_potion
			if is_inverse_of_last_move:
				i -= 1
				continue
		
		# finally, execute this
		commands.start_new_turn()
		var cmd := CommandTurn.new(target_potion, start_potion)
		commands.execute_command(cmd)
		
		# track states to prevent going in circles (this includes START STATE!), if turned on
		# @NOTE: must be done BEFORE adding it to solution, otherwise we have a faulty solution of course!
		if forbid_repetitive_states and num_attempts <= max_attempts:
			var new_hash := get_state_hash()
			if state_hashes.has(new_hash):
				commands.undo_last_turn()
				continue
			else:
				state_hashes.append(new_hash)
		
		last_move = { "from": potions.find(start_potion), "to": potions.find(target_potion) }
		solution.append(last_move)
	
	solution.reverse()

func count_chunks() -> int:
	var num := 0
	for potion in potions:
		num += potion.count()
	return num

func count_chunks_wrong() -> int:
	var num := 0
	for potion in potions:
		num += potion.count_wrong()
	return num

func count_turns() -> int:
	return solution.size()

func clean_up(num_attempts : int) -> bool:
	if num_attempts > max_attempts: return true
	
	# too few moves
	if count_turns() < num_moves_bounds.x: return false
	
	# not enough variation at start
	# (it can happen that we randomly end up with something already nearly finished)
	var diversity_ratio := count_chunks_wrong() / float(count_chunks())
	if diversity_ratio < initial_state_diversity_factor: return false
	
	return true
