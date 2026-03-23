extends RefCounted
class_name PotionData

var chunks : Array[ChunkData] = []
var max_size := 6

## Assigned color; you beat puzzle by filling it with only chunks of that color
var color : ChunkData.ColorName

## Index in the original puzzle array of potions
var index := -1

signal changed()

func _init(s:int) -> void:
	max_size = s

func add_chunks(c:Array[ChunkData]) -> void:
	for chunk in c:
		add_chunk(chunk)

func add_chunk(c:ChunkData) -> void:
	chunks.append(c)
	changed.emit()

func remove_chunk(c:ChunkData) -> void:
	chunks.erase(c)
	changed.emit()

func remove_chunks(c:Array[ChunkData]) -> void:
	for chunk in c:
		remove_chunk(chunk)

func remove_colors(c:Array[ChunkData.ColorName]) -> void:
	var arr : Array[ChunkData.ColorName] = c.duplicate(false)
	for i in range(chunks.size() -1, -1, -1):
		if arr.has(chunks[i].color):
			arr.erase(chunks[i].color)
			remove_chunk(chunks[i])

func get_chunk_at(idx:int) -> ChunkData:
	return chunks[idx]

func get_colors() -> Array[ChunkData.ColorName]:
	var arr : Array[ChunkData.ColorName]
	arr.assign(chunks.map(func(c:ChunkData): return c.get_color()))
	return arr

func has_color(c:ChunkData.ColorName) -> bool:
	return get_colors().has(c)

func is_full() -> bool:
	return count() >= max_size

func is_empty() -> bool:
	return count() <= 0

func has_overflowed() -> bool:
	return count() > max_size

func get_space_available() -> int:
	return max_size - count()

func count() -> int:
	return chunks.size()

func count_wrong() -> int:
	var num := 0
	for chunk in chunks:
		if chunk.color != color:
			num += 1
	return num

# @NOTE: We don't need to add the potion color or size as it never changes during play
func get_hash() -> String:
	var hs := ""
	for chunk in chunks:
		hs += str(chunk.color)
	return hs

func get_first_chunk() -> ChunkData:
	return chunks.front()

func get_last_chunk() -> ChunkData:
	return chunks.back()

func clone() -> PotionData:
	var pd := PotionData.new(max_size)
	pd.chunks = chunks.duplicate(false)
	pd.color = self.color
	return pd

func get_neighbor_chunks(c:ChunkData) -> Array[ChunkData]:
	var idx := chunks.find(c)
	var nbs : Array[ChunkData] = []
	if idx > 0:
		nbs.append(chunks[idx-1])
	if idx < (count() - 1):
		nbs.append(chunks[idx+1])
	return nbs

func is_all_same_color() -> bool:
	if count() <= 1: return true
	
	var first_color : ChunkData.ColorName = chunks.front().color
	for i in range(1, count()):
		if chunks[i].color != first_color: return false
	return true
