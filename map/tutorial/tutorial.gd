extends Node2D
class_name Tutorial

@export var indicator : Node2D
@export var audio_explanation : AudioStreamPlayer
@export var audio_narrate : AudioStreamPlayer
var tween_active : Tween
var active := false
var narrate := false

func _ready() -> void:
	active = PuzzleFramework.get_setting_value("show_tutorial") and PuzzleFramework.get_puzzle_difficulty_level() == PuzzleDifficulty.Difficulty.EASIEST
	narrate = PuzzleFramework.get_setting_value("narrate_colors")

func on_turn_changed(from:Potion, to:Potion, turn:int) -> void:
	indicator.hide()
	
	if narrate and (not active or turn >= 2):
		audio_narrate.stream = load("res://map/chunks/sounds/" + ChunkData.get_audio_for(to.data.color) + ".ogg")
		audio_narrate.play()

	if turn >= 1 or not active: return
	if turn == 0: play_audio()
	highlight_move(from)

func play_audio() -> void:
	if PuzzleFramework.num_attempts_same_puzzle >= 2 or PuzzleFramework.num_attempts >= 2: 
		return 
	audio_explanation.play()

func highlight_move(p:Potion) -> void:
	if tween_active:
		PuzzleTween.force_tween_completion(tween_active)
		tween_active = null
	
	var mid_pos := 0.5 * (p.global_position + p.get_position_of_top())
	tween_active = PuzzleTutorial.play_pointer_tween(indicator, mid_pos)

func disappear() -> void:
	audio_explanation.stop()
	audio_narrate.stop()
	indicator.hide()
