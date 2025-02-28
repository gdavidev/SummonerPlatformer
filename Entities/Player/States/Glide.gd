extends State

func enter(_old_state):
	return
	

func exit(_new_state):
	return
	

func handle_input(event):
	if event as InputEvent and event.is_action_released("jump"):
		emit_signal("finished", "Fall")
	if event.is_action_pressed("jump"):
		parent.jump_buffer.start()
	

func update(_delta):
	parent.get_x_input()
	parent.get_y_input()
	parent.apply_gravity(_delta)
	parent.handle_move_input()
	parent.apply_movement(_delta)
	parent.update_wall_direction()
	parent.cap_gravity_glide()
	
	if parent.is_grounded:
		emit_signal("finished", "Idle")
	if parent.wall_direction != 0 and parent.wall_leaving_cooldown.is_stopped()\
								  and parent.leaving_ledge_time.is_stopped():
		emit_signal("finished", "WallSlide")
	

func _on_Animation_finished(_anim_name):
	return
	
