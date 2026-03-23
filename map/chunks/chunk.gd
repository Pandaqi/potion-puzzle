extends Node2D
class_name Chunk

var data : ChunkData

@export var sprite : Sprite2D
@export var anim_player : AnimationPlayer

func set_from_data(cd:ChunkData) -> void:
	data = cd
	sprite.modulate = cd.get_color_as_object()
	
	anim_player.speed_scale = randf_range(0.5, 1.2)
	anim_player.play("bubble_float")
	if randf() <= 0.5: anim_player.play_backwards("bubble_float")
	show()

func unset_data() -> void:
	hide()
	data = null
	anim_player.stop()
