extends Node2D

@export var save_file : String
func _ready() -> void:
	for l in range(5):
		var tilemap = TileMapLayer.new()
		tilemap.tile_set = load("res://Scenes/Assets/Base.tres")
		tilemap.name = str(l)
		$Tilemaps.add_child(tilemap)
		
	await RenderingServer.frame_post_draw
	var image = $SubViewport.get_texture().get_image()
	for c in image.get_width():
		for l in image.get_height():
			var height = snappedf(image.get_pixel(c, l).a, 0.25)*4
			for h in range(height+1):
				$Tilemaps.get_node(str(int(h))).set_cell(Vector2(c, l), 1, Vector2(8, 5))
			
	var file = FileAccess.open("res://Scenes/Maps/"+save_file+".isoterrain", FileAccess.WRITE)
	var result = []
	for f in $Tilemaps.get_children():
		result.append(f.tile_map_data)
	file.store_string(str(result))

	get_tree().quit()
