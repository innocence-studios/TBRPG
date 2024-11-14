extends AnimatableBody2D
var dir : Vector2
func _process(_delta: float) -> void:
	var vec = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	vec = Vector2(sign(vec.x),sign(vec.y)).normalized()
	if vec.x:dir=vec
	if vec.y:dir=vec
	if vec == Vector2.ZERO:%AnimationTree.set("parameters/Transition/transition_request", "Idle")
	else:%AnimationTree.set("parameters/Transition/transition_request", "Run")
	
	$Interact.rotation = dir.angle()
	
	if dir.x==-1:
		$Sprite2D.flip_h=true
	elif dir.x==1:
		$Sprite2D.flip_h=false
	
	_test_interact()
	move_and_collide(vec*5)

func _test_interact():
	if $Interact.is_colliding():
		if Input.is_action_just_pressed("interact"):
			$Interact.get_collider().interact()
