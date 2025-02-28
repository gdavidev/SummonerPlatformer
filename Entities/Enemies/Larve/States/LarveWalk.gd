extends State

func _ready():
	return
	

func enter(_old_state):
	get_node("../../Body/Sprite").flip_v = false
	anim.play("Ready")
	

func exit(_new_state):
	return
	

func handle_input(_event):
	return
	

func update(_delta):
	parent.apply_movement(_delta)
	parent.apply_gravity(_delta)
	parent.move_foward()
	parent.damage_colliding_body()
	
	if parent.is_falling == true:
		emit_signal("finished", "Falling")
	

func _on_Animation_finished(_anim_name):
	return
	

