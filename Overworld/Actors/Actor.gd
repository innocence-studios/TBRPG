extends Node2D
class_name Actor

var current_tile = Vector3i(0,0,0)
var next_tile = Vector3i(0,0,0)

func move_to_next_tile():
	global_position.x = next_tile.x
	global_position.y = next_tile.y
	global_position.y -= (next_tile.z+1) * 8
	z_index = (next_tile.z*2)+2
	current_tile = next_tile
