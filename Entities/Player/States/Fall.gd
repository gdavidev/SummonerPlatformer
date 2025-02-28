extends State

func enter(_old_state):
	if anim.current_animation == "WallJump":
		anim.play("Fall")
	else:
		anim.play("Pre-Fall")
		anim.queue("Fall")
		

func exit(_new_state):
	anim.clear_queue()
	

func handle_input(event):
	if event as InputEvent:
		if event.is_action_pressed("jump"):
			if parent.jump_count == 0:
				parent.jump_count = 1
			if parent.jump_count < 1:
				if !parent.coyote_timer.is_stopped():
					parent.coyote_timer.stop()
					parent.jump()
					parent.jump_count = 0
					emit_signal("finished", "Jump")
				else:
					parent.jump()
					emit_signal("finished", "DoubleJump")
			else:
				parent.jump_buffer.start()
	
	

func update(_delta):
	parent.get_x_input()
	parent.get_y_input()
	parent.apply_gravity(_delta)
	parent.handle_move_input()
	parent.apply_movement(_delta)
	parent.update_wall_direction()
	parent.handle_glide_call()
	
	
	if parent.velocity.y < 0:
		emit_signal("finished", "Jump")
	if parent.is_grounded:
		emit_signal("finished", "Idle")
	if parent.wall_direction != 0 and parent.wall_leaving_cooldown.is_stopped()\
				and !parent.is_ground_near.is_colliding():
		emit_signal("finished", "WallSlide")
	if parent.velocity.y > 0:
		if parent.leaving_ledge_time.is_stopped() and parent.get_ledge():
			emit_signal("finished", "LedgeGrab")
	

func _on_GlideCallTimer_timeout():
	emit_signal("finished", "Glide")
