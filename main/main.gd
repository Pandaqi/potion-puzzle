extends Node2D

var gen : PuzzleGenerator
@export var vis : PuzzleVisualizer

func _ready() -> void:
	gen = PuzzleGenerator.new()
	gen.generate()
	vis.visualize(gen)
