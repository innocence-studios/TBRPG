extends ActionEffect

func _on_start():
	caster.next_tile = target[0]
	caster.move_to_next_tile()
