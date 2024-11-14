extends AnimatableBody2D
class_name Interactable

@export_enum("Dialogue") var type: String

func _ready() -> void:
	collision_layer = 4
	collision_mask = 2

func interact():
	%Player.set_process(false)
	DialogueManager.show_example_dialogue_balloon(load("res://Scenes/Resources/Dialogue/AlexusWannaBeACrab.dialogue"), "Start")
	await DialogueManager.dialogue_ended
	%Player.set_process(true)
