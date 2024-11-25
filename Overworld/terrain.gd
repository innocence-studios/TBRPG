extends Node2D
class_name Terrain

var base
var render
var highlight
var mask

@export var load_file : String
func _load():
	for c in get_children():
		c.free()
	var file = FileAccess.open("res://Overworld/Maps/"+load_file+".isoterrain", FileAccess.READ).get_as_text()
	var data = JSON.parse_string(file)
	var i = 0
	base = TileMapLayerGroup.new()
	base.tile_set = load("res://Overworld/Assets/Base.tres")
	add_child(base)
	for f in data:
		var tilemap = TileMapLayer.new()
		base.add_child(tilemap)
		tilemap.owner = base
		tilemap.name = str("Floor",i)
		tilemap.tile_set = base.tile_set
		tilemap.set_tile_map_data_from_array(f)
		i+=1

func _ready() -> void:
	_load()
	base.visible = false
	render = TileMapLayerGroup.new()
	render.tile_set = load("res://Overworld/Assets/Render.tres")
	add_child(render)
	highlight = TileMapLayerGroup.new()
	highlight.tile_set = load("res://Overworld/Assets/Highlight.tres")
	add_child(highlight)
	mask = TileMapLayerGroup.new()
	mask.tile_set = load("res://Overworld/Assets/Mask.tres")
	add_child(mask)
	mask.visible = false
	
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



const _VOID_ATLAS_COORDS = Vector2i(0, 0)
const _INVALID_TILE = Vector3i(-1, -1, -1)

var _highlights: Array[Vector3i]

func _get_selected_tile(local: Vector2, stack: Array[Vector3i]) -> Vector3i:
	var origin = Vector2(16, 8)
	for actual in stack:
		# Calculate which pixel to inspect in the sprite.
		var offset: Vector2i = local - render.map_to_local(
				Vector2i(actual.x-actual.z, actual.y-actual.z)) + origin
		
		var atlas_cell = base.get_cell_atlas_coords(actual.z, Vector2i(actual.x, actual.y))
		var source_id = base.get_cell_source_id(actual.z, Vector2i(actual.x, actual.y))
		var source = mask.tile_set.get_source(source_id)
		var source_cell = source.get_tile_at_coords(atlas_cell)
		var tile_origin = Vector2i(
			source_cell.x * source.texture_region_size.x,
			source_cell.y * source.texture_region_size.y,
		)
		var check = source.texture.get_image().get_pixelv(tile_origin + offset)
		
		# We have an opaque part of the block and cannot check tiles lower in the stack.
		if check == Color.BLACK:
			break
		
		# We have found a target tile.
		if check == Color.WHITE:
			return actual
			
		# Else, we have hit a transparent part of the mask, and should continue
		# to the next tile in the stack.
	
	return _INVALID_TILE

func _get_neighbors_apparent(local: Vector2) -> Array[Vector2i]:
	var apparent = render.local_to_map(local)
	var offset = local - render.map_to_local(apparent)
	# If X < 0, then the cursor lies on the left half of the tile; this means
	# that we need to check for partial left-side occlusion.
	if offset.x < 0:
		return [
			apparent,                                  # D
			Vector2i(apparent.x - 1, apparent.y),      # B
			Vector2i(apparent.x - 1, apparent.y - 1),  # A

		]
	return [
			apparent,                                  # D
			Vector2i(apparent.x, apparent.y - 1),      # C
			Vector2i(apparent.x - 1, apparent.y - 1),  # A
	]

func _cell_is_occupied(layer: int, actual: Vector2i) -> bool:
	return base.get_cell_source_id(layer, actual) >= 0 and (
		base.get_cell_atlas_coords(layer, actual) != _VOID_ATLAS_COORDS)

func _get_raytrace_stack(apparent_neighbors: Array[Vector2i]) -> Array[Vector3i]:
	var stack: Array[Vector3i] = []
	for layer in range(base.get_layers_count() - 1, -1, -1):
		for apparent in apparent_neighbors:
			var actual = Vector2i(
				apparent.x + layer,
				apparent.y + layer)
			if _cell_is_occupied(layer, actual):
				stack.append_array([Vector3i(actual.x, actual.y, layer)])
	return stack

func select_tile(local: Vector2) -> Vector3i:
	return _get_selected_tile(
		local,
		_get_raytrace_stack(
			_get_neighbors_apparent(local)))

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
