extends Node2D
class_name ActorGroup

func _process(delta: float) -> void:
	if get_children()==[]:
		get_node("../..").switch_scene(get_node("../..").SCENE_TYPE.COMBAT,"fields")

func add_actor(max_health:int,alignement:String,actions:Array[String],sprites:Array[String],move:int,jump:int):
	var actor = Actor.new()
	add_child(actor)
	
	actor.max_health=max_health
	actor.alignement=alignement
	actor.actions=actions
	actor.sprites=sprites
	actor.move=move
	actor.jump=jump
	
	actor.scene = get_node("..")
	actor.main = get_node("../..")
	actor.terrain = get_node("..").terrain
	actor.init()
	actor.set_process(true)
