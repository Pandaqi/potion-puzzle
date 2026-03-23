extends Node2D
class_name PotionSmall

@export var base : Sprite2D
@export var overlay : Sprite2D
@export var shine : Sprite2D

var base_size := 256.0
var unfocused_scale := Vector2.ONE
var active_tween : Tween

func set_color(c:ChunkData.ColorName) -> void:
	overlay.modulate = ChunkData.convert_color_to_object(c)

func set_size(size:float) -> void:
	var new_scale := size / base_size * Vector2.ONE
	set_scale(new_scale)
	unfocused_scale = new_scale

func focus() -> void:
	var tw := get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	var dur := randf_range(0.2, 0.4)
	tw.tween_property(self, "scale", 1.5*unfocused_scale, dur)
	tw.parallel().tween_property(self, "modulate:a", 1.0, dur)
	active_tween = tw
	shine.show()

func unfocus() -> void:
	if active_tween: 
		active_tween.stop()
		active_tween = null
	
	shine.hide()
	modulate.a = 0.67
	set_scale(unfocused_scale)
	
