extends Node2D
class_name TileMapLayerGroup

@export var tile_set : TileSet

func get_layers_count():
	return get_child_count()

func remove_layer(id:int):
	get_child(id).queue_free()

func add_layer(id:int):
	var layer = TileMapLayer.new()
	layer.tile_set = tile_set
	add_child(layer)
	move_child(layer, id)

func local_to_map(pos:Vector2):
	return get_child(0).local_to_map(pos)
	
func map_to_local(pos:Vector2):
	return get_child(0).map_to_local(pos)

func set_layer_y_sort_enabled(id:int, yes:bool):
	get_child(id).set_y_sort_enabled(yes)

func set_layer_z_index(id, index):
	get_child(id).set_z_index(index)

func get_used_cells(layer):
	return get_child(layer).get_used_cells()

func get_cell_atlas_coords(layer, coords):
	return get_child(layer).get_cell_atlas_coords(coords)

func get_cell_source_id(layer, coords):
	return get_child(layer).get_cell_source_id(coords)

func set_cell(layer: int, coords: Vector2i, source_id: int = -1, atlas_coords: Vector2i = Vector2i(-1, -1), alternative_tile: int = 0):
	get_child(layer).set_cell(coords, source_id, atlas_coords, alternative_tile)
	
func erase_cell(layer, coords):
	get_child(layer).erase_cell(coords)

func get_tile_map_data_as_array():
	var result = []
	for c in get_children():
		result.append(c.tile_map_data)
	return result

func offset_layers(offset:Vector2):
	var i = 0
	for c in get_children():
		c.position = i * offset
		i += 1
