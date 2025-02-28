extends State

func enter(_old_state):
	return
	

func exit(_new_state):
	return
	

func handle_input(_event):
	return
	

func update(_delta):
	parent.apply_gravity(_delta)
	parent.apply_movement(_delta)
	

func _on_Animation_finished(_anim_name):
	return
	

