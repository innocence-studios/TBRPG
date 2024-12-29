extends Node2D
class_name Actor

@export var alignement : String
@export var actions : Array[String]
@export var sprite : Texture2D
var current_tile = Vector3i(0,0,0)
var path_to_next_tile : Array[Vector3i] = []

func _ready() -> void:
	#recalculate_sprite()
	var sprite2d := Sprite2D.new()
	add_child(sprite2d)
	sprite2d.texture = sprite
	sprite2d.position.y = -4

func move_to_next_tile():
	global_position.x = %Terrain.render.map_to_local(Vector2(path_to_next_tile[-1].x, path_to_next_tile[-1].y)).x
	global_position.y = %Terrain.render.map_to_local(Vector2(path_to_next_tile[-1].x, path_to_next_tile[-1].y)).y
	global_position.y -= (path_to_next_tile[-1].z+1) * 8
	z_index = path_to_next_tile[-1].z

func recalculate_sprite():
	var segment = sprite.get_height()/16
	for s in segment:
		var sprite2d := Sprite2D.new()
		add_child(sprite2d)
		sprite2d.texture = sprite
		sprite2d.region_enabled = true
		
		sprite2d.region_rect=Rect2(
			0,s*16,sprite.get_width(),16
		)
		
		sprite2d.position.y = -12+s*16
		sprite2d.z_index = 2-s
