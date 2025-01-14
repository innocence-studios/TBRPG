extends Node2D

var current_actor : int = 0:
	set(value):
		if actors.get_children().is_empty():
			get_parent().switch_scene(get_parent().SCENE_TYPE.COMBAT, "fields")
		else:
			for a in actors.get_children():
				a.characard.hide()
			actors.get_children()[value].characard.show()
			current_actor = value

var current_action : Action

enum PROMPTS {
	NONE,
	SELECTTILE_PATH,
	SELECTTILE_SHAPE,
	VALIDATETILE
}
var current_prompt : PROMPTS

### Tile Shape Library

var crown : Array[Vector3i] = [
	Vector3i(-3,3,0),Vector3i(0,3,0),Vector3i(3,3,0),
	Vector3i(-2,2,0),Vector3i(0,2,0),Vector3i(2,2,0),
	Vector3i(-2,1,0),Vector3i(0,1,0),Vector3i(2,1,0),
	Vector3i(-2,0,0),Vector3i(-1,0,0),Vector3i(1,0,0),Vector3i(2,0,0),
	Vector3i(-2,-1,0),Vector3i(-1,-1,0),Vector3i(0,-1,0),Vector3i(1,-1,0),Vector3i(2,-1,0),]
var shaft : Array[Vector3i] = [
	Vector3i(0, 5, 0),
	Vector3i(-1,4,0),Vector3i(0,4,0),Vector3i(1,4,0),
	Vector3i(-1,3,0),Vector3i(0,3,0),Vector3i(1,3,0),
	Vector3i(-1,2,0),Vector3i(0,2,0),Vector3i(1,2,0),
	Vector3i(-1,1,0),Vector3i(0,1,0),Vector3i(1,1,0),
	Vector3i(-1,0,0),Vector3i(1,0,0),
	Vector3i(-3,-1,0),Vector3i(-2,-1,0),Vector3i(3,-1,0),Vector3i(2,-1,0),
	Vector3i(-4,-2,0),Vector3i(-1,-2,0),Vector3i(1,-2,0),Vector3i(4,-2,0),
	Vector3i(-4,-3,0),Vector3i(-1,-3,0),Vector3i(1,-3,0),Vector3i(4,-3,0),
	Vector3i(-3,-4,0),Vector3i(-2,-4,0),Vector3i(3,-4,0),Vector3i(2,-4,0),]

var tile
var target : Array[Vector3i] = [Vector3i.ZERO]:
	set(value):
		target=value
		if current_action:
			if current_action.name == "Move":
				$MovePath.clear_points()
				for p in value:
					$MovePath.add_point(Vector2(
						terrain.render.map_to_local(Vector2(p.x, p.y)).x,
						terrain.render.map_to_local(Vector2(p.x, p.y)).y-(p.z)*8
						))

var terrain
var actors

func _process(_delta):
	%FPS.text=str(Engine.get_frames_per_second())

	var camera_motion = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()
	$Camera2D.position += camera_motion*4

	prompt()
	
func _on_action_pressed() -> void:
	%ActionsMenu.clear()
	for i in actors.get_children()[current_actor].actions:
		%ActionsMenu.add_item(i)
	%ActionsMenu.popup()
	%Action.disabled = true

func _on_actions_menu_index_pressed(index: int) -> void:
	current_action = load("Actions/Resources/"+%ActionsMenu.get_item_text(index)+".tres")
	if current_action.name == "Move":
		current_prompt = PROMPTS.SELECTTILE_PATH
	else: current_prompt = PROMPTS.SELECTTILE_SHAPE
	
	%ActionPlayer.set_script(current_action.action_script)
	%ActionPlayer.caster = actors.get_children()[current_actor]
	%ActionCursor.texture = load(current_action.cursor)
	
	tile = actors.get_children()[current_actor].current_tile
	target = [actors.get_children()[current_actor].current_tile]
	
	%ActionsMenu.visible = false

func prompt():
	match current_prompt:

		PROMPTS.NONE:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			target = [Vector3i.ZERO]
			terrain.highlight_tiles([])
			%Action.disabled = false
			%ActionCursor.visible = false

		PROMPTS.SELECTTILE_SHAPE:
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
			target = [Vector3i.ZERO]
			
			var tile2d = select_tile(tile)
			if terrain.get_top_tile(tile2d).z != -1:
				#if abs(terrain.get_top_tile(tile2d)-tile.z) <= 0:
				tile = terrain.get_top_tile(tile2d)
			
				
			
			terrain.highlight_tiles(terrain.get_shape_from_tile(tile, current_action.shape, 3))
			
			if Input.is_action_just_pressed("escape"):
				current_prompt = PROMPTS.NONE
				
			if tile:
				if Input.is_action_just_pressed("accept"):
					target = terrain.get_shape_from_tile(tile, current_action.shape, 3)
					
					%ActionCursor.global_position.x = terrain.render.map_to_local(Vector2(tile.x, tile.y)).x
					%ActionCursor.global_position.y = terrain.render.map_to_local(Vector2(tile.x, tile.y)).y
					%ActionCursor.global_position.y -= (tile.z+1) * 8
					%ActionCursor.z_index = (tile.z*2)+2
					%ActionCursor.visible = true
					
					current_prompt = PROMPTS.VALIDATETILE

		PROMPTS.SELECTTILE_PATH:
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
			
			var tile2d = select_tile(tile)
			
			if terrain.get_top_tile(tile2d).z != -1:
				if abs(terrain.get_top_tile(tile2d).z-tile.z) <= actors.get_children()[current_actor].jump:
					if not target.has(terrain.get_top_tile(tile2d)):
						if target.size()<=actors.get_children()[current_actor].move:
							tile = terrain.get_top_tile(tile2d)
					else:
						if target.size()>=2:
							if terrain.get_top_tile(tile2d) == target[-2]:
								tile = terrain.get_top_tile(tile2d)

			if tile != target[-1]:
				if target.size()>=2:
					if tile == target[-2]:
						var new_array = target.duplicate()
						new_array.pop_back()
						target = new_array
					else: 
						var new_array = target.duplicate()
						new_array.append(tile)
						target = new_array
				else: 
					var new_array = target.duplicate()
					new_array.append(tile)
					target = new_array
				
			
			terrain.highlight_tiles([tile])
			
			if Input.is_action_just_pressed("escape"):
				current_prompt = PROMPTS.NONE
				
			if tile:
				if Input.is_action_just_pressed("accept"):
					
					%ActionCursor.global_position.x = terrain.render.map_to_local(Vector2(tile.x, tile.y)).x
					%ActionCursor.global_position.y = terrain.render.map_to_local(Vector2(tile.x, tile.y)).y
					%ActionCursor.global_position.y -= (tile.z+1) * 8
					%ActionCursor.z_index = (tile.z*2)+2
					%ActionCursor.visible = true
					
					current_prompt = PROMPTS.VALIDATETILE

		PROMPTS.VALIDATETILE:
			
			if Input.is_action_just_pressed("accept"):
				%ActionPlayer.target = target
				%ActionPlayer.start()
				target = [Vector3i.ZERO]
				
				if current_actor + 1 < actors.get_children().size(): current_actor += 1
				else: current_actor = 0
				
				
				current_prompt = PROMPTS.NONE
			elif Input.is_action_just_pressed("escape"):
				if current_action.name == "Move":
					current_prompt = PROMPTS.SELECTTILE_PATH
				else: current_prompt = PROMPTS.SELECTTILE_SHAPE

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

func init(file:String, actor_list:Array=[]):
	set_process(false)
	terrain = Terrain.new()
	add_child(terrain)
	terrain.load_file = file
	terrain.init()
	
	tile = terrain.get_top_tile(Vector2i(1,1))
	
	actors = ActorGroup.new()
	actors.set_process(false)
	add_child(actors)
	
	for i in range(2):
		var actions : Array[String] = [
			"move",
			"fire",
			"blood_ritual"
		]
		var sprites : Array[String] = [
			"Graphics/knight0.png",
			"Graphics/knight1.png",
			"Graphics/knight2.png",
			"Graphics/knight3.png",
			"Graphics/knight4.png",
		]
		actors.add_actor(1,"Goblins",actions,sprites,100,100)

	set_process(true)
	actors.set_process(true)
