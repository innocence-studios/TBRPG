extends Node

### Map
var last_map : Resource
var last_pos : Vector2

### Inventory
var balance : float = 0.0
var inventory : Array[String]

### Iso Terrain
func get_shape_from_tile(coords:Vector3i, shape:Array[Vector3i], rotation:int):
	var result = []
	for i in shape:
		if rotation == 0:
			result.append(Vector3i(coords.x+i.x,coords.y+i.y,coords.z+i.z))
		elif rotation == 1:
			result.append(Vector3i(coords.x+i.y,coords.y+i.x,coords.z+i.z))
		elif rotation == 2:
			result.append(Vector3i((coords.x-i.x),(coords.y-i.y),coords.z+i.z))
		elif rotation == 3:
			result.append(Vector3i((coords.x-i.y),(coords.y-i.x),coords.z+i.z))
	return result
