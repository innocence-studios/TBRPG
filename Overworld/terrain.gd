extends Node2D
class_name Terrain


@export var load_file : String
func _load():
	for c in get_children():
		c.free()
	var file = FileAccess.open("res://Overworld/Maps/"+load_file+".isoterrain", FileAccess.READ).get_as_text()
	var data = JSON.parse_string(file)
	var i = 0
	for f in data:
		var tilemap = TileMapLayer.new()
		add_child(tilemap)
		tilemap.name = str("Floor",i)
		tilemap.tile_set = load("res://Overworld/Tiles.tres")
		tilemap.position.y = -8*i
		tilemap.owner = self
		tilemap.set_tile_map_data_from_array(f)
		i+=1

func _ready():_load()
