extends State

func _ready():
	return
	

func enter(_old_state):
	parent.rotation = 0
	get_node("../../Body/Sprite2D").flip_v = true
	anim.play("Ready")
	

func exit(_new_state):
	return
	

func handle_input(_event):
	return
	

func update(_delta):
	parent.apply_movement(_delta)
	parent.apply_gravity(_delta)
	parent.damage_colliding_body()
	
	if parent.is_falling == false:
		emit_signal("finished", "Walk")
	

func _on_Animation_finished(_anim_name):
	return
	
