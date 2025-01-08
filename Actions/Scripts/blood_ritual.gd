extends ActionEffect

func _on_start():
	for t in target:
		var blood
		if t == target[0]:
			blood = load("res://Actions/VFX/blood_ritual2.tscn").instantiate()
		else:
			blood = load("res://Actions/VFX/blood_ritual1.tscn").instantiate()
		add_child(blood)
		blood.global_position.x = %Terrain.render.map_to_local(Vector2(t.x, t.y)).x
		blood.global_position.y = %Terrain.render.map_to_local(Vector2(t.x, t.y)).y
		blood.global_position.y -= (t.z+1) * 8
		blood.z_index = (t.z*2)+2
		
		var actor = %Terrain.get_actor_at_tile(t)
		if actor: actor.damage(50, Global.DAMAGE.FIRE)
