extends Node2D
class_name Actor

var canvas_layer : CanvasLayer
var characard : Control

@export var max_health : int
var health: int :
	set(value):
		health = value
		if characard:characard.hp = value
		if health<=0:
			queue_free()
			get_node("/root/Scene").actors.erase(self)

@export var alignement : String
@export var actions : Array[String]
@export var sprites : Array[Texture2D]
var current_tile = Vector3i(0,0,0)
var path_to_next_tile : Array[Vector3i] = []

func _ready() -> void:
	recalculate_sprite()
	health = max_health
	
	canvas_layer = CanvasLayer.new()
	characard = load("res://Scenes/GUI/character_card.tscn").instantiate()
	characard.text = name
	characard.max_hp = max_health
	characard.visible = false
	canvas_layer.add_child(characard)
	add_child(canvas_layer)

func move_to_next_tile():
	global_position.x = %Terrain.render.map_to_local(Vector2(path_to_next_tile[-1].x, path_to_next_tile[-1].y)).x
	global_position.y = %Terrain.render.map_to_local(Vector2(path_to_next_tile[-1].x, path_to_next_tile[-1].y)).y
	global_position.y -= (path_to_next_tile[-1].z+1) * 8
	z_index = path_to_next_tile[-1].z
	current_tile = path_to_next_tile[-1]

func recalculate_sprite():
	var i=0
	for s in sprites:
		var sprite2d := Sprite2D.new()
		add_child(sprite2d)
		sprite2d.texture = s
		sprite2d.position.y = -i*8
		sprite2d.z_index = i
		i+=1

func damage(damage:int, element:Global.DAMAGE):
	health -= damage
