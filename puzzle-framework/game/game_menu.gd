extends CanvasLayer
class_name PuzzleGameMenu

@export var container : MarginContainer

@export var button_back : TextureButton
@export var button_restart : TextureButton
@export var button_undo : TextureButton
@export var button_next : TextureButton

@export var allow_back := true
@export var allow_restart := true
@export var allow_undo := false
@export var allow_next := true

@export var size := 96.0

var commands : PuzzleCommands

func _ready() -> void:
	button_back.pressed.connect(_on_button_back_pressed)
	button_restart.pressed.connect(_on_button_restart_pressed)
	button_undo.pressed.connect(_on_button_undo_pressed)
	button_next.pressed.connect(_on_button_next_pressed)
	
	if not allow_back: button_back.hide()
	if not allow_undo: button_undo.hide()
	if not allow_next: button_next.hide()
	if not allow_restart: button_restart.hide()
	
	container.custom_minimum_size.y = size
	
	PuzzleFramework.puzzle_done.connect(_on_puzzle_done)

func _on_button_back_pressed() -> void:
	PuzzleFramework.go_back_to_menu()

func _on_button_restart_pressed() -> void:
	PuzzleFramework.reload_current_puzzle()

func _on_button_undo_pressed() -> void:
	if (not commands) or (not allow_undo): return
	commands.undo_last_turn()

func _on_button_next_pressed() -> void:
	PuzzleFramework.load_new_puzzle()

func _on_puzzle_done(_player_won:bool) -> void:
	queue_free()
