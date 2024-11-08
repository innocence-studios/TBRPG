extends Node2D

func _on_combat_trigger_body_entered(body: Node2D) -> void:
	if body == $Player:
		print("test")
