extends State

func _ready():
	return
	

func enter(_old_state):
	anim.play("Staggered")
	parent.velocity.x = 0
	

func exit(_new_state):
	return
	

func update(_delta):
	parent.apply_movement(_delta)
	parent.apply_gravity(_delta)
	

func _on_Animation_finished(_anim_name):
	return
	

func _on_StaggeredTime_timeout():
	if parent.is_falling == true:
		emit_signal("finished", "Falling")
	else:
		emit_signal("finished", "Walk")
	
