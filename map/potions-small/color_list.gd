extends Node2D
class_name ColorList

var list : Array[PotionSmall]  = []
var element_size := 64
@export var potion_small_scene : PackedScene

func _ready() -> void:
	get_viewport().size_changed.connect(_on_size_changed)
	_on_size_changed()

func _on_size_changed() -> void:
	position.x = 0.5 * get_viewport_rect().size.x

func refresh() -> void:
	var num_targets := count()
	var offset_targets := -0.5 * (num_targets - 1) * element_size * Vector2.RIGHT
	for i in range(num_targets):
		var pos := offset_targets + i * element_size * Vector2.RIGHT
		list[i].set_position(pos)

func count() -> int:
	return list.size()

func add_target_with_color(c:ChunkData.ColorName) -> void:
	var target := potion_small_scene.instantiate()
	target.set_color(c)
	target.set_size(element_size)
	add_target(target)

func add_target(target:PotionSmall) -> void:
	add_child(target)
	list.append(target)
	refresh()

func remove_target(target:PotionSmall) -> void:
	remove_child(target)
	target.queue_free()
	refresh()

func destroy() -> void:
	for i in range(list.size() -1, -1, -1):
		remove_target(list[i])
