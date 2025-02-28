extends State

func enter(_old_state):
	if _old_state != "Jump":
		parent_sm.conserved_jump_velocity = 0
	

func exit(_new_state):
	return
	

func handle_input(event):
	if event.is_action_pressed("jump"):
		parent.jump_buffer.start()
	

func update(_delta):
	parent.apply_movement(_delta)
	
	if parent.is_grounded:
		parent.knockback_lose_control_time.stop()
		emit_signal("finished", "Idle")
	if parent.velocity.y > 0:
		parent.knockback_lose_control_time.stop()
		if parent.leaving_ledge_time.is_stopped() and parent.get_ledge():
			emit_signal("finished", "LedgeGrab")
	

func _on_Animation_finished(_anim_name):
	return
	

func _on_KnockBackLoseControlTime_timeout():
	if !parent.jump_buffer.is_stopped() and parent.jump_count < 2:
		parent.jump_count = 1
		parent.velocity.x = 0
		parent.jump()
		emit_signal("finished", "Jump")
	else:
		parent.velocity = Vector2.ZERO
		if parent.sm.conserved_jump_velocity < 0:
			parent.velocity.y = parent.sm.conserved_jump_velocity/2
			parent.sm.conserved_jump_velocity = 0
			emit_signal("finished", "Jump")
		else:
			emit_signal("finished", "Fall")
