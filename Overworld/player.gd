extends AnimatableBody2D
var last_vec : Vector2
var dir : Vector2
func _process(_delta: float) -> void:
	var vec = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	vec = Vector2(sign(vec.x),sign(vec.y))
	if last_vec.x != 0:vec.y=0
	if last_vec.y != 0:vec.x=0
	last_vec.x=vec.x
	last_vec.y=vec.y
	if vec.x:dir.x=vec.x
	if vec.y:dir.y=vec.y
	if vec == Vector2.ZERO:%AnimationTree.set("parameters/Transition/transition_request", "Idle")
	else:%AnimationTree.set("parameters/Transition/transition_request", "Run")
	
	if dir.x==-1:
		$Sprite2D.flip_h=true
	elif dir.x==1:
		$Sprite2D.flip_h=false
	
	move_and_collide(vec*5)
