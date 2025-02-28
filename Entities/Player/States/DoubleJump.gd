extends State

func enter(_old_state):
	anim.play("Jump")
	

func exit(_new_state):
	return
	

func handle_input(event):
	if event.is_action_released("jump") && parent.velocity.y < parent.min_jump_velocity:
			parent.velocity.y = parent.min_jump_velocity
	if event.is_action_pressed("jump"):
		parent.jump_buffer.start()
	

func update(_delta):
	parent.get_x_input()
	parent.get_y_input()
	parent.apply_gravity(_delta)
	parent.handle_move_input()
	parent.apply_movement(_delta)
	parent.update_wall_direction()
	
	if parent.velocity.y > 0:
		emit_signal("finished", "Fall")
	if parent.wall_direction != 0 and parent.wall_leaving_cooldown.is_stopped():
		emit_signal("finished", "WallSlide")
	if parent.is_grounded:
		emit_signal("finished", "Idle")
	
	parent.sm.conserved_jump_velocity = parent.velocity.y
	
