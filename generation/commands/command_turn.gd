extends PuzzleCommand
class_name CommandTurn

var from : PotionData
var to : PotionData
var chunk_moved : ChunkData

func _init(f:PotionData, t:PotionData) -> void:
	from = f
	to = t

func do(cmds:PuzzleCommands) -> bool:
	var chunk_to_move := from.get_last_chunk()
	from.remove_chunk(chunk_to_move)
	if not cmds.generating:
		await cmds.vis.play_chunk_transfer_tween(from, chunk_to_move, to)
	to.add_chunk(chunk_to_move)
	chunk_moved = chunk_to_move
	return true

func undo(cmds:PuzzleCommands) -> bool:
	to.remove_chunk(chunk_moved)
	if not cmds.generating:
		await cmds.vis.play_chunk_transfer_tween(to, chunk_moved, from)
	from.add_chunk(chunk_moved)
	return true
