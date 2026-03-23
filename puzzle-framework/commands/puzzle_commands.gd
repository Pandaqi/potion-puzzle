extends Node
class_name PuzzleCommands

## Contains all commands executed on every turn => Array[Array[PuzzleCommand]]
var history : Array = []

## True while it's busy doing/undoing commands (which allows you to check if you're able/allowed to make a new action happen or not)
var busy := false

## You can set this to true while generating because you might want certain things to not happen (rr happen differently) while generating compared to while playing
@export var generating := false

## Whether it plays a sound effect upon rewind
@export var play_audio := false

signal do_started()
signal do_finished()
signal undo_started()
signal undo_finished()

func has_turns() -> bool:
	return history.size() > 0

func is_busy() -> bool:
	return busy

func get_current_turn() -> Array[PuzzleCommand]:
	var arr : Array[PuzzleCommand] = []
	if not has_turns(): return arr
	arr.assign(history.back())
	return arr

func register_command(cmd:PuzzleCommand) -> void:
	history.back().append(cmd)

func start_new_turn() -> void:
	history.append([])

func delete_last_turn() -> void:
	history.pop_back()

func execute_command(cmd:PuzzleCommand) -> void:
	busy = true
	do_started.emit()
	
	register_command(cmd)
	await cmd.do(self)
	
	do_finished.emit()
	busy = false

func undo_last_turn() -> void:
	if not has_turns(): return
	if is_busy(): return
	
	busy = true
	undo_started.emit()
	
	play_undo_audio()
	
	var commands : Array[PuzzleCommand] = get_current_turn()
	commands.reverse()
	
	for cmd in commands:
		await cmd.undo(self)
	
	delete_last_turn()
	
	undo_finished.emit()
	busy = false

func play_undo_audio() -> void:
	if not play_audio: return
	
	var ap := AudioStreamPlayer.new()
	ap.stream = load("res://puzzle-framework/ui/ui_undo.ogg")
	get_tree().get_root().add_child(ap)
	PuzzleAudio.play_audio_nice(ap)
	await ap.finished
	ap.queue_free()
