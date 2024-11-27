extends Node2D

enum PROMPTS {
	NONE,
	SELECTTILE,
	VALIDATETILE
}
var current_prompt : PROMPTS

### Tile Shape Library

var cross : Array[Vector3i] = [
		Vector3i(-1, 0, 0),
		Vector3i(1, 0, 0),
		Vector3i(0, -1, 0),
		Vector3i(0, 1, 0),
		Vector3i.ZERO,
		Vector3i(-2, 0, 0),
		Vector3i(2, 0, 0),
		Vector3i(0, -2, 0),
		Vector3i(0, 2, 0),
		]
var crown : Array[Vector3i] = [
	Vector3i(-3,3,0),Vector3i(0,3,0),Vector3i(3,3,0),
	Vector3i(-2,2,0),Vector3i(0,2,0),Vector3i(2,2,0),
	Vector3i(-2,1,0),Vector3i(0,1,0),Vector3i(2,1,0),
	Vector3i(-2,0,0),Vector3i(-1,0,0),Vector3i.ZERO,Vector3i(1,0,0),Vector3i(2,0,0),
	Vector3i(-2,-1,0),Vector3i(-1,-1,0),Vector3i(0,-1,0),Vector3i(1,-1,0),Vector3i(2,-1,0),
]

var shaft : Array[Vector3i] = [
	Vector3i(0, 5, 0),
	Vector3i(-1,4,0),Vector3i(0,4,0),Vector3i(1,4,0),
	Vector3i(-1,3,0),Vector3i(0,3,0),Vector3i(1,3,0),
	Vector3i(-1,2,0),Vector3i(0,2,0),Vector3i(1,2,0),
	Vector3i(-1,1,0),Vector3i(0,1,0),Vector3i(1,1,0),
	Vector3i(-1,0,0),Vector3i.ZERO,Vector3i(1,0,0),
	Vector3i(-3,-1,0),Vector3i(-2,-1,0),Vector3i(3,-1,0),Vector3i(2,-1,0),
	Vector3i(-4,-2,0),Vector3i(-1,-2,0),Vector3i(1,-2,0),Vector3i(4,-2,0),
	Vector3i(-4,-3,0),Vector3i(-1,-3,0),Vector3i(1,-3,0),Vector3i(4,-3,0),
	Vector3i(-3,-4,0),Vector3i(-2,-4,0),Vector3i(3,-4,0),Vector3i(2,-4,0),
]
var single_dot : Array[Vector3i] = [Vector3i.ZERO]

func _process(_delta):
	%FPS.text=str(Engine.get_frames_per_second())
	var mpos = get_global_mouse_position()
	var tile = $Terrain.select_tile($Terrain.render.to_local(mpos))
	$Terrain.highlight_tiles(Global.get_shape_from_tile(tile, single_dot))

	if Input.is_action_just_pressed("zoom_plus"):
		$Camera2D.zoom += Vector2(0.1,0.1)
	elif Input.is_action_just_pressed("zoom_minus"):
		$Camera2D.zoom -= Vector2(0.1,0.1)
		
	if Input.is_action_pressed("ui_up") and $Camera2D.position.y >= -120:
		$Camera2D.position.y-=4
	if Input.is_action_pressed("ui_down") and $Camera2D.position.y <= 480:
		$Camera2D.position.y+=4
	if Input.is_action_pressed("ui_left") and $Camera2D.position.x >= -120:
		$Camera2D.position.x-=4
	if Input.is_action_pressed("ui_right") and $Camera2D.position.x <= 480:
		$Camera2D.position.x+=4

	if current_prompt == PROMPTS.NONE: pass
	elif current_prompt == PROMPTS.SELECTTILE:
		if tile:
			if Input.is_action_just_pressed("click"):
				$Player.next_tile.x = $Terrain.render.map_to_local(Vector2(tile.x, tile.y)).x
				$Player.next_tile.y = $Terrain.render.map_to_local(Vector2(tile.x, tile.y)).y
				$Player.next_tile.z = tile.z 
				current_prompt = PROMPTS.VALIDATETILE
	elif current_prompt == PROMPTS.VALIDATETILE:
		if Input.is_action_just_pressed("ui_accept"):
			$Player.move_to_next_tile()
			current_prompt = PROMPTS.NONE
	


func _on_move_pressed() -> void:
	current_prompt = PROMPTS.SELECTTILE
	$CanvasLayer/Combat/Move.queue_free()
