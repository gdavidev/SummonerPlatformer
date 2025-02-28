extends State


func enter(_old_state):
	parent.is_jumping = true
	parent.damage_boost_time_window.stop()
	parent.damage_boost_travel_time.start()
	

func exit(_new_state):
	return
	

func handle_input(event):
	if event.is_action_pressed("jump"):
		parent.jump_buffer.start()
	

func update(_delta):
	parent.apply_gravity(_delta)
	parent.apply_movement(_delta)
	parent.update_wall_direction()
	
	if parent.is_grounded:
		emit_signal("finished", "Idle")
	if parent.velocity.y > 0:
		if parent.leaving_ledge_time.is_stopped() and parent.get_ledge():
			emit_signal("finished", "LedgeGrab")
	

func _on_Animation_finished(_anim_name):
	return
	

func _on_DamageBoostTravelTime_timeout():
	if !parent.jump_buffer.is_stopped() and parent.jump_count < 2:
		parent.jump_count = 1
		parent.velocity.x = 0
		parent.jump()
		emit_signal("finished", "Jump")
	else:
		emit_signal("finished", "Fall")
