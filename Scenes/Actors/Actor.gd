extends Node2D
class_name Actor

var current_tile = Vector3i(0,0,0)
var next_tile = Vector3i(0,0,0)

func move_to_next_tile():
	print("move")
	global_position.x = %Terrain.render.map_to_local(Vector2(next_tile.x, next_tile.y)).x
	global_position.y = %Terrain.render.map_to_local(Vector2(next_tile.x, next_tile.y)).y
	global_position.y -= (next_tile.z+1) * 8
	z_index = (next_tile.z*2)+2
