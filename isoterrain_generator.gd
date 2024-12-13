@tool
extends Node2D

@export var size : Vector2i
@export_range(1, 99) var height = 1
@export_tool_button("Regenerate TileMapLayers") var regenerate_tilemaps = _regenerate_tilemaps
func _regenerate_tilemaps():
	for c in get_children():
		c.free()
	for f in height:
		var tilemap = TileMapLayer.new()
		add_child(tilemap)
		tilemap.name = str("Floor",f)
		tilemap.tile_set = load("res://Scenes/Assets/Base.tres")
		tilemap.owner = self

@export var save_file : String
@export_tool_button("Save .isoterrain") var save = _save
func _save():
	var file = FileAccess.open("res://Scenes/Maps/"+save_file+".isoterrain", FileAccess.WRITE)
	var result = []
	for f in get_children():
		result.append(f.tile_map_data)
		
	var hmap = []
	for x in size.x:
		var ax = []
		for y in size.y:
			for l in get_child_count():
				if get_child(get_child_count()-l-1).get_cell_source_id(Vector2i(x,y))!=-1:
					ax.append(get_child_count()-l)
				else:ax.append(-1)
		hmap.append(ax)
	print(hmap)
	
	file.store_string(str([result,hmap]))

@export var load_file : String
@export_tool_button("Load .isoterrain") var load = _load
func _load():
	for c in get_children():
		c.free()
	var file = FileAccess.open("res://Scenes/Maps/"+load_file+".isoterrain", FileAccess.READ).get_as_text()
	var data = JSON.parse_string(file)[0]
	var i = 0
	for f in data:
		var tilemap = TileMapLayer.new()
		add_child(tilemap)
		tilemap.name = str("Floor",i)
		tilemap.tile_set = load("res://Scenes/Assets/Base.tres")
		tilemap.owner = self
		tilemap.set_tile_map_data_from_array(f)
		i+=1
