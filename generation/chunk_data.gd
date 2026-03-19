class_name ChunkData

enum ColorName
{
	RED,
	BLUE,
	GREEN,
	ORANGE,
	PURPLE,
	YELLOW,
	BLACK,
	WHITE
}

var color : ColorName
var final := false

var constraints_equal : Array[ChunkData] = []
var constraints_unequal : Array[ChunkData] = []

func _init(c:ColorName) -> void:
	set_color(c)

func add_constraint_equal(c:ChunkData) -> void:
	constraints_equal.append(c)
	c.constraints_equal.append(self)

func add_constraint_unequal(c:ChunkData) -> void:
	constraints_unequal.append(c)
	c.constraints_unequal.append(self)

static func get_all_colors() -> Array[ColorName]:
	var arr : Array[ColorName] = []
	arr.assign(ColorName.values())
	return arr

static func convert_color_to_object(c:ColorName) -> Color:
	if c == ColorName.RED: return Color.RED
	if c == ColorName.BLUE: return Color.BLUE
	if c == ColorName.GREEN: return Color.GREEN
	if c == ColorName.ORANGE: return Color.ORANGE
	if c == ColorName.PURPLE: return Color.PURPLE
	if c == ColorName.YELLOW: return Color.YELLOW
	if c == ColorName.BLACK: return Color.BLACK
	if c == ColorName.WHITE: return Color.WHITE
	return Color.WHITE

func get_color_as_object() -> Color:
	return convert_color_to_object(color)

func set_color(c:ColorName) -> void:
	color = c
	final = true

func get_color() -> ColorName:
	return color

func is_final() -> bool:
	return final
