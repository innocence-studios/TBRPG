extends Node2D

var actions = ["move"]

var current_action : Action

var mouse_select = true

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
	Vector3i(-2,-1,0),Vector3i(-1,-1,0),Vector3i(0,-1,0),Vector3i(1,-1,0),Vector3i(2,-1,0),]
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
	Vector3i(-3,-4,0),Vector3i(-2,-4,0),Vector3i(3,-4,0),Vector3i(2,-4,0),]
var single_dot : Array[Vector3i] = [Vector3i.ZERO]

var highlights : Array = []
var tile
var validation_tile = Vector3i(0,0,0)
func _process(_delta):
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
		
	if Input.is_action_just_pressed("switch_selection_mode"):
		mouse_select = !mouse_select
		
	%FPS.text=str(Engine.get_frames_per_second())
	
	prompt()
	

func _on_action_pressed() -> void:
	%ActionsMenu.clear()
	for i in actions:
		%ActionsMenu.add_item(i)
	%ActionsMenu.popup()
	%Action.disabled = true

func _on_actions_menu_index_pressed(index: int) -> void:
	current_prompt = PROMPTS.SELECTTILE
	current_action = load("Actions/"+%ActionsMenu.get_item_text(index)+".tres")
	
	%ActionPlayer.set_script(current_action.action_script)
	%ActionPlayer.caster = $Player
	
	%ActionsMenu.visible = false

func prompt():
	match current_prompt:
		
		PROMPTS.NONE:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			validation_tile = Vector3i.ZERO
			
			highlights = []
			$Terrain.highlight_tiles(highlights)
			
			%Action.disabled = false
			
		PROMPTS.SELECTTILE:
			validation_tile = Vector3i.ZERO
			
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
			
			if mouse_select:
				var mpos = get_global_mouse_position()
				tile = $Terrain.select_tile($Terrain.render.to_local(mpos))
			else:
				var tile2d = select_tile(tile)
				print("tile : ",str(tile),", tile2D : ",str(tile2d),", height : ",str($Terrain.get_top_tile(tile2d)))
				tile = Vector3i(tile2d.x, tile2d.y, $Terrain.get_top_tile(tile2d))
			highlights = Global.get_shape_from_tile(tile, single_dot, 3)
			$Terrain.highlight_tiles(highlights)
			
			if Input.is_action_just_pressed("escape"):
				current_prompt = PROMPTS.NONE
				
			if tile:
				if Input.is_action_just_pressed("click"):
					$ActionPlayer.target[0].x = $Terrain.render.map_to_local(Vector2(tile.x, tile.y)).x
					$ActionPlayer.target[0].y = $Terrain.render.map_to_local(Vector2(tile.x, tile.y)).y
					$ActionPlayer.target[0].z = tile.z 
					validation_tile = tile
					
					$ActionCursor.global_position.x = $Terrain.render.map_to_local(Vector2(tile.x, tile.y)).x
					$ActionCursor.global_position.y = $Terrain.render.map_to_local(Vector2(tile.x, tile.y)).y
					$ActionCursor.global_position.y -= (tile.z+1) * 8
					$ActionCursor.z_index = (tile.z*2)+2
					
					current_prompt = PROMPTS.VALIDATETILE
					
		PROMPTS.VALIDATETILE:
			
			if Input.is_action_just_pressed("accept"):
				%ActionPlayer.start()
				validation_tile = Vector3i.ZERO
				current_prompt = PROMPTS.NONE
			elif Input.is_action_just_pressed("escape"):
				current_prompt = PROMPTS.SELECTTILE

func _on_actions_menu_popup_hide() -> void:
	current_prompt = PROMPTS.NONE
	%Action.disabled = false

func select_tile(coords):
	if Input.is_action_just_pressed("select_left"):
		coords.x -= 1
	elif Input.is_action_just_pressed("select_right"):
		coords.x += 1
	elif Input.is_action_just_pressed("select_up"):
		coords.y -= 1
	elif Input.is_action_just_pressed("select_down"):
		coords.y += 1
	return Vector2i(coords.x, coords.y)
