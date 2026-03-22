extends PuzzleCommand
class_name CommandTurn

var from : PotionData
var to : PotionData
var chunk_moved : ChunkData

func _init(f:PotionData, t:PotionData) -> void:
	from = f
	to = t

func do(_cmds:PuzzleCommands) -> bool:
	var chunk_to_move := from.get_last_chunk()
	from.remove_chunk(chunk_to_move)
	to.add_chunk(chunk_to_move)
	chunk_moved = chunk_to_move
	return true

func undo(_cmds:PuzzleCommands) -> bool:
	to.remove_chunk(chunk_moved)
	from.add_chunk(chunk_moved)
	return true
