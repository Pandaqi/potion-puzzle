class_name PuzzleGenerator

## Number of potions to work towards
var num_potion_bounds := Vector2i(4, 6)

## Maximum size of potions before they overflow
var potion_size_bounds := Vector2i(3, 4)

## The [min,max] number of chunks with which every potion starts
var potion_start_contents_bounds := Vector2i(2,4)

## The number of moves the final puzzle solution should have
var num_moves_bounds := Vector2i(3, 7)

## Exact final configuration of potions + chunks presented to player as puzzle
var potions : Array[PotionData]

## Solution found by generator => { from: start_potion, to: target_potion }
var solution : Array[Dictionary]

## History of steps by generator, used for debugging
var history : Array[Array]

func generate() -> void:
	create_random_setup()
	take_turns()

func create_random_setup() -> void:
	var potion_size := randi_range(potion_size_bounds.x, potion_size_bounds.y)
	var num_potions := randi_range(num_potion_bounds.x, num_potion_bounds.y)
	
	var all_colors := ChunkData.get_all_colors()
	all_colors.shuffle()
	for i in range(num_potions):
		var p := PotionData.new(potion_size)
		potions.append(p)
		
		var color_chosen : ChunkData.ColorName = all_colors.pop_back()
		p.color = color_chosen
	
		var num_chunks_start := randi_range(potion_start_contents_bounds.x, mini(potion_size, potion_start_contents_bounds.y))
		for a in range(num_chunks_start):
			p.add_chunk(ChunkData.new(color_chosen))

func save_state_to_history() -> void:
	var state : Array[PotionData] = []
	for potion in potions:
		state.append(potion.clone())
	history.append(state)

func get_random_potion_not_full(exclude : Array[PotionData] = []) -> PotionData:
	var potions_not_full := potions.filter(func(p:PotionData): return not p.is_full() and not exclude.has(p))
	if potions_not_full.size() <= 0: return null
	return potions_not_full.pick_random()

func get_random_potion_with_content(exclude : Array[PotionData] = []) -> PotionData:
	var potions_with_content := potions.filter(func(p:PotionData): return not p.is_empty() and not exclude.has(p))
	if potions_with_content.size() <= 0: return null
	return potions_with_content.pick_random()

func take_turns() -> void:
	solution = []
	history = []
	save_state_to_history()
	
	var num_steps := randi_range(num_moves_bounds.x, num_moves_bounds.y)
	for i in range(num_steps):
		var start_potion := get_random_potion_not_full()
		if not start_potion: break
		
		var target_potion := get_random_potion_with_content([start_potion])
		if not target_potion: break
		
		var chunk_to_move := target_potion.get_last_chunk()
		target_potion.remove_chunk(chunk_to_move)
		start_potion.add_chunk(chunk_to_move)
	
		solution.append({ "from": potions.find(start_potion), "to": potions.find(target_potion) })
		save_state_to_history()
	
	solution.reverse()

func count_turns() -> int:
	return solution.size()
