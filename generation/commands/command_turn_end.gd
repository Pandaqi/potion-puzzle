extends PuzzleCommand
class_name CommandTurnEnd

var vis : PuzzleVisualizer

func _init( v:PuzzleVisualizer) -> void:
	vis = v

func do(_cmds:PuzzleCommands) -> bool:
	vis.update_turn_number(+1)
	return true

func undo(_cmds:PuzzleCommands) -> bool:
	vis.update_turn_number(-1)
	return true
