extends Node2D
class_name Terrain

var base
var render
var highlight
var heightmap

@export var load_file : String
func _load():
	for c in get_children():
		c.free()
	var file = FileAccess.open("res://Scenes/Maps/"+load_file+".isoterrain", FileAccess.READ).get_as_text()
	var data = JSON.parse_string(file)
	var i = 0
	base = TileMapLayerGroup.new()
	base.tile_set = load("res://Scenes/Assets/Base.tres")
	add_child(base)
	for f in data[0]:
		var tilemap = TileMapLayer.new()
		base.add_child(tilemap)
		tilemap.owner = base
		tilemap.name = str("Floor",i)
		tilemap.tile_set = base.tile_set
		tilemap.set_tile_map_data_from_array(f)
		i+=1
	heightmap = data[1]

func _ready() -> void:
	
	_load()
	base.visible = false
	render = TileMapLayerGroup.new()
	render.tile_set = load("res://Scenes/Assets/Render.tres")
	add_child(render)
	highlight = TileMapLayerGroup.new()
	highlight.tile_set = load("res://Scenes/Assets/Highlight.tres")
	add_child(highlight)
	
	for i in range(render.get_layers_count()):
		render.remove_layer(i)
	for i in range(highlight.get_layers_count()):
		highlight.remove_layer(i)
	
	for i in range(base.get_layers_count()):
		render.add_layer(i)
		render.set_layer_y_sort_enabled(i, true)
		render.set_layer_z_index(i, i)
		render.offset_layers(Vector2(0,8))
		
		# Sprites from Highlight may need to sit behind some cells. This means
		# we want to associate the z-layer data along-side the cell coordinates.
		highlight.add_layer(i)
		highlight.set_layer_y_sort_enabled(i, true)
		highlight.set_layer_z_index(i, i)
		highlight.offset_layers(Vector2(0,8))
		
		# Copy corresponding textures to the rendered TileMap.
		for c in base.get_used_cells(i):
			var atlas = base.get_cell_atlas_coords(i, c)
			render.set_cell(
				i,
				Vector2i(c.x-i, c.y-i),
				base.get_cell_source_id(i, c),
				atlas)

const _INVALID_TILE = Vector3i(-1, -1, -1)
var _highlights: Array[Vector3i]

func get_top_tile(coords:Vector2i):
	if heightmap.size()>coords.x:
		if heightmap[coords.x].size()>coords.y:
			return Vector3i(coords.x, coords.y, heightmap[coords.x][coords.y])
	return Vector3i(coords.x, coords.y, -1)

func get_shape_from_tile(coords:Vector3i, shape:Array[Vector3i], rot:int) -> Array[Vector3i] :
	var result : Array[Vector3i] = [coords]
	for i in shape:
		if rot == 0:
			result.append(Vector3i(coords.x+i.x,coords.y+i.y,get_top_tile(Vector2i(coords.x+i.x,coords.y+i.y)).z))
		elif rot == 1:
			result.append(Vector3i(coords.x+i.y,coords.y+i.x,get_top_tile(Vector2i(coords.x+i.y,coords.y+i.x)).z))
		elif rot == 2:
			result.append(Vector3i((coords.x-i.x),(coords.y-i.y),get_top_tile(Vector2i(coords.x-i.x,coords.y-i.y)).z))
		elif rot == 3:
			result.append(Vector3i((coords.x-i.y),(coords.y-i.x),get_top_tile(Vector2i(coords.x-i.y,coords.y-i.x)).z))
	return result

func highlight_tiles(cells: Array):
	for c in _highlights:
		highlight.erase_cell(c.z, Vector2i(c.x-c.z, c.y-c.z))

	_highlights.clear()

	for c in cells:
		if c != _INVALID_TILE:
			_highlights.append_array([c])
			highlight.set_cell(
				c.z,
				Vector2i(c.x-c.z, c.y-c.z),
				base.get_cell_source_id(c.z, Vector2i(c.x, c.y)),
				base.get_cell_atlas_coords(c.z, Vector2i(c.x, c.y)))
