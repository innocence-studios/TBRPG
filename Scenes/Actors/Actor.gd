extends Node2D
class_name Actor

var canvas_layer : CanvasLayer
var characard : Control

var main
var scene
var terrain

@export var max_health : int
var health: int :
	set(value):
		health = value
		if characard:characard.hp = value
		if health<=0:queue_free()

@export var alignement : String
@export var actions : Array[String]
@export var sprites : Array[String]
var current_tile
var path_to_next_tile : Array[Vector3i] = []

@export var move : int = 8
@export var jump : int = 2

func _ready() -> void:set_process(false)

func init() -> void:
	recalculate_sprite()
	health = max_health
	
	canvas_layer = CanvasLayer.new()
	characard = load("res://Scenes/GUI/character_card.tscn").instantiate()
	characard.text = name
	characard.max_hp = max_health
	characard.visible = false
	canvas_layer.add_child(characard)
	add_child(canvas_layer)
	
	current_tile = terrain.get_top_tile(Vector2i(1,1))

func move_to_next_tile():
	print(path_to_next_tile)
	for i in path_to_next_tile:
		global_position.x = terrain.render.map_to_local(Vector2(i.x, i.y)).x
		global_position.y = terrain.render.map_to_local(Vector2(i.x, i.y)).y
		global_position.y -= (i.z+1) * 8
		z_index = i.z
		current_tile = i
		await get_tree().create_timer(0.5).timeout

func recalculate_sprite():
	var i=0
	for s in sprites:
		var sprite2d := Sprite2D.new()
		add_child(sprite2d)
		sprite2d.texture = load("res://"+s)
		sprite2d.position.y = -i*8
		sprite2d.z_index = i
		#sprite2d.clip_children = CanvasItem.CLIP_CHILDREN_ONLY
		
		#var sprite_seethrough := Sprite2D.new()
		#sprite2d.add_child(sprite_seethrough)
		#sprite_seethrough.texture = s
		#sprite_seethrough.z_index=RenderingServer.CANVAS_ITEM_Z_MAX
		#sprite_seethrough.modulate=Color("000000ff")
		#sprite_seethrough.show_behind_parent = true
		
		i+=1
		
		

func damage(damage:int, element:Global.DAMAGE):
	health -= damage
