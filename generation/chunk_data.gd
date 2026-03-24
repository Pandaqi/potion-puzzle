class_name ChunkData

enum ColorName
{
	RED,
	BLUE,
	GREEN,
	ORANGE,
	PURPLE,
	YELLOW,
	PINK,
	CYAN,
	BROWN,
	BLACK,
	GRAY,
	WHITE
}

enum ShapeName
{
	ARROW,
	CIRCLE,
	ELLIPSE,
	HEART,
	HEXAGON,
	RECTANGLE,
	SQUARE,
	STAR,
	TRIANGLE
}

var color : ColorName
var final := false

var constraints_equal : Array[ChunkData] = []
var constraints_unequal : Array[ChunkData] = []

static var color_to_sound : Dictionary[ColorName, String] = {
	ColorName.RED: "red",
	ColorName.BLUE: "blue",
	ColorName.GREEN: "green",
	ColorName.ORANGE: "orange",
	ColorName.PURPLE: "purple",
	ColorName.YELLOW: "yellow",
	ColorName.PINK: "pink",
	ColorName.CYAN: "cyan",
	ColorName.BROWN: "brown",
	ColorName.BLACK: "black",
	ColorName.GRAY: "gray",
	ColorName.WHITE: "white",
}

static var shape_to_sound : Dictionary[ShapeName, String] = {
	ShapeName.ARROW: "arrow",
	ShapeName.CIRCLE: "circle",
	ShapeName.ELLIPSE: "ellipse",
	ShapeName.HEART: "heart",
	ShapeName.HEXAGON: "hexagon",
	ShapeName.RECTANGLE: "rectangle",
	ShapeName.SQUARE: "square",
	ShapeName.STAR: "star",
	ShapeName.TRIANGLE: "triangle",
}

static var color_to_shape : Dictionary[ColorName, ShapeName] = {
	ColorName.RED: ShapeName.CIRCLE,
	ColorName.BLUE: ShapeName.ELLIPSE,
	ColorName.GREEN: ShapeName.SQUARE,
	ColorName.ORANGE: ShapeName.RECTANGLE,
	ColorName.PURPLE: ShapeName.TRIANGLE,
	ColorName.YELLOW: ShapeName.ARROW,
	ColorName.PINK: ShapeName.HEXAGON,
	ColorName.CYAN: ShapeName.HEART,
	ColorName.BLACK: ShapeName.STAR,
	# @NOTE: BROWN, GRAY, and WHITE are removed
}

static var shape_to_frame : Dictionary[ShapeName, int] = {
	ShapeName.CIRCLE: 0,
	ShapeName.ELLIPSE: 1,
	ShapeName.SQUARE: 2,
	ShapeName.RECTANGLE: 3,
	ShapeName.TRIANGLE: 4,
	ShapeName.ARROW: 5,
	ShapeName.HEXAGON: 6,
	ShapeName.HEART: 7,
	ShapeName.STAR: 8,
}


func _init(c:ColorName) -> void:
	set_color(c)

func add_constraint_equal(c:ChunkData) -> void:
	constraints_equal.append(c)
	c.constraints_equal.append(self)

func add_constraint_unequal(c:ChunkData) -> void:
	constraints_unequal.append(c)
	c.constraints_unequal.append(self)

static func get_audio_for(c:ColorName) -> String:
	return convert_color_to_audio(c) if PuzzleVisualizer.uses_colors() else convert_shape_to_audio(convert_color_to_shape(c))

static func get_all_colors() -> Array[ColorName]:
	var arr : Array[ColorName] = []
	arr.assign(ColorName.values())
	return arr

static func convert_color_to_audio(c:ColorName) -> String:
	return color_to_sound[c]

static func convert_color_to_shape(c:ColorName) -> ShapeName:
	return color_to_shape[c]

static func convert_shape_to_audio(s:ShapeName) -> String:
	return shape_to_sound[s]

static func convert_shape_to_frame(s:ShapeName) -> int:
	return shape_to_frame[s]

static func convert_color_to_object(c:ColorName) -> Color:
	if c == ColorName.RED: return Color.RED
	if c == ColorName.BLUE: return Color.BLUE
	if c == ColorName.GREEN: return Color.GREEN
	if c == ColorName.ORANGE: return Color.ORANGE
	if c == ColorName.PURPLE: return Color.PURPLE
	if c == ColorName.YELLOW: return Color.YELLOW
	if c == ColorName.PINK: return Color.PINK
	if c == ColorName.CYAN: return Color.CYAN
	if c == ColorName.BROWN: return Color.CHOCOLATE
	if c == ColorName.BLACK: return Color(0.25, 0.25, 0.25) # full black looks ugly and makes modulation just completely black too
	if c == ColorName.GRAY: return Color.GRAY
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
