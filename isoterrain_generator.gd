@tool
extends Node2D

@export_range(1, 99) var height = 1
@export_tool_button("Regenerate TileMapLayers") var regenerate_tilemaps = _regenerate_tilemaps
func _regenerate_tilemaps():
	for c in get_children():
		c.free()
	for f in height:
		var tilemap = TileMapLayer.new()
		add_child(tilemap)
		tilemap.name = str("Floor",f)
		tilemap.tile_set = load("res://Overworld/Assets/Base.tres")
		tilemap.owner = self

@export var save_file : String
@export_tool_button("Save .isoterrain") var save = _save
func _save():
	var file = FileAccess.open("res://Overworld/Maps/"+save_file+".isoterrain", FileAccess.WRITE)
	var result = []
	for f in get_children():
		result.append(f.tile_map_data)
	file.store_string(str(result))

@export var load_file : String
@export_tool_button("Load .isoterrain") var load = _load
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
		tilemap.tile_set = load("res://Overworld/Assets/Base.tres")
		tilemap.owner = self
		tilemap.set_tile_map_data_from_array(f)
		i+=1
