extends State

func _ready():
	return
	

func enter(_old_state):
	anim.play("Died")
	

func exit(_new_state):
	return
	

func handle_input(_event):
	return
	

func update(_delta):
	parent.apply_gravity(_delta)
	

func _on_Animation_finished(_anim_name):
	return
	
