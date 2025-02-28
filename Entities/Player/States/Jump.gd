extends State

func enter(_old_state):
	if _old_state == "WallSlide":
		anim.play("Pre-WallJump")
		anim.queue("WallJump")
	else:
		anim.play("Pre-Jump")
		anim.queue("Jump")
		

func exit(_new_state):
	anim.clear_queue()
	

func handle_input(event):
	if event as InputEvent:
		if event.is_action_pressed("jump") and parent.jump_count < 1:
			parent.jump()
			emit_signal("finished", "DoubleJump")
		if event.is_action_released("jump") && parent.velocity.y < parent.min_jump_velocity:
				parent.velocity.y = parent.min_jump_velocity
		

func update(_delta):
	if parent.wall_jump_lose_control_time.is_stopped():
		parent.get_x_input()
	parent.handle_move_input()
	parent.get_y_input()
	parent.apply_gravity(_delta)
	parent.apply_movement(_delta)
	parent.update_wall_direction()
	
	if parent.is_grounded:
		emit_signal("finished", "Idle")
	if parent.velocity.y > 0:
		emit_signal("finished", "Fall")
	if parent.wall_direction != 0 and parent.wall_leaving_cooldown.is_stopped()\
				and !parent.is_ground_near.is_colliding():
		emit_signal("finished", "WallSlide")
	
	parent.sm.conserved_jump_velocity = parent.velocity.y
	
