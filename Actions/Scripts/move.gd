extends ActionEffect


func _on_start():
	caster.path_to_next_tile = target
	caster.move_to_next_tile()
