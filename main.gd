extends Node2D

enum SCENE_TYPE {
	COMBAT,
	SCENE,
	OVERWORLD,
	CUTSCENE
}
func switch_scene(type:SCENE_TYPE,file:String):
	for c in get_children():
		remove_child(c)
	match type:
		SCENE_TYPE.COMBAT:
			var scene = load("res://Scenes/Combat.tscn").instantiate()
			add_child(scene)
			scene.init(file)

func _ready() -> void:
	switch_scene(SCENE_TYPE.COMBAT, "throne")
