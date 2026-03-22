extends Node
class_name PuzzleFrameworkAutoload

@export_group("Game Core")
@export var game_name := "GameName"
@export var game_version := "1.0"
@export var game_tagline := "Educational Puzzle Game"
@export var creator_credit := "The Wayward Melody"

@export_group("Menu")
@export var menu_pattern_enabled := false
@export var menu_scene_custom : PackedScene

@export_group("Difficulties & Campaign")
var current_difficulty := 0
@export var difficulties : Array[PuzzleDifficulty] = []
var difficulties_by_id : Dictionary[PuzzleDifficulty.Difficulty, PuzzleDifficulty] = {}

@export_group("Settings & Configuration")
@export var settings : Array[PuzzleSetting] = []
var settings_by_id : Dictionary[String, PuzzleSetting] = {}

var puzzle_seed := 0
var state := State.MENU
var audio : PuzzleAudio

enum State
{
	MENU,
	LOAD,
	PUZZLE,
	DONE
}

signal puzzle_started()
signal puzzle_done(player_won:bool)

func _enter_tree() -> void:
	audio = PuzzleAudio.new()
	add_child(audio)
	
	for setting in settings:
		settings_by_id[setting.key] = setting
	
	for difficulty in difficulties:
		difficulties_by_id[difficulty.difficulty] = difficulty

func _ready() -> void:
	pass

func go_back_to_menu() -> void:
	change_state(State.MENU)
	get_tree().change_scene_to_file("res://puzzle-framework/menu/menu.tscn")

func reload_current_puzzle() -> void:
	seed(puzzle_seed)
	change_state(State.LOAD)
	get_tree().reload_current_scene()

func load_new_puzzle(diff := get_puzzle_difficulty_level()) -> void:
	current_difficulty = difficulties.find(difficulties_by_id[diff])
	puzzle_seed = randi()
	seed(puzzle_seed)
	change_state(State.LOAD)
	get_tree().change_scene_to_file("res://main/main.tscn")

func start_puzzle() -> void:
	change_state(State.PUZZLE)
	audio.state_audio.play()
	puzzle_started.emit()

func finish_puzzle(player_won := false) -> void:
	change_state(State.DONE)
	puzzle_done.emit(player_won)

func change_state(s:State) -> void:
	state = s

func get_puzzle_difficulty() -> PuzzleDifficulty:
	return difficulties[current_difficulty]

func get_puzzle_difficulty_level() -> PuzzleDifficulty.Difficulty:
	return get_puzzle_difficulty().difficulty

func apply_difficulty_settings(obj) -> void:
	var diff := get_puzzle_difficulty()
	for key in diff.properties:
		obj[key] = diff.properties[key]

func has_settings() -> bool:
	return settings.size() > 0

func get_setting_value(key:String) -> Variant:
	if not (key in settings_by_id): return false
	return settings_by_id[key].get_value_safe()
