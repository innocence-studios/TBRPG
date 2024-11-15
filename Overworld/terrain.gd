extends Node2D

@export_file("*.isoterrain") var terrain
var parsed_terrain : Array[Array]
var test_terrain : Array[Array] = [
	[[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,1,1,0,0,0],
	[0,0,0,1,1,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0]],
	[[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,1,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0]]
]

func _ready() -> void:
	_parse_file()
	_create_tilemaps()

func _parse_file() -> void:
	if not terrain:
		parsed_terrain = test_terrain
		return
func _create_tilemaps() -> void:
	var i = 0
	for f in parsed_terrain:
		var tilemap = TileMapLayer.new()
		tilemap.name = "f"+str(i)
		add_child(tilemap)
		i+=1
