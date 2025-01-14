extends ActionEffect

func _on_start():
	for t in target:
		var fire = load("res://Actions/VFX/fireVFX.tscn").instantiate()
		add_child(fire)
		fire.global_position.x = get_node("..").terrain.render.map_to_local(Vector2(t.x, t.y)).x
		fire.global_position.y = get_node("..").terrain.render.map_to_local(Vector2(t.x, t.y)).y
		fire.global_position.y -= (t.z+1) * 8
		fire.z_index = (t.z*2)+2
