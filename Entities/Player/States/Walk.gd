extends State

func enter(_old_state):
	anim.play("Walk")
	

func exit(_new_state):
	return
	

func handle_input(event):
	if event as InputEvent:
		if event.is_action_pressed("jump"):
			if Input.is_action_pressed("down"): #use input anyways if you need to hold
				if parent.check_colliding_raycasts(parent.drop_thru_rays):
					parent.set_collision_mask_value(parent.DROPTHRU_BIT, false)
			else:
				if !parent.coyote_timer.is_stopped():
					parent.coyote_timer.stop()
					parent.jump()
					emit_signal("finished", "Jump")
				if parent.check_colliding_raycasts(parent.ceilling_rays) == false:
						parent.jump()
						emit_signal("finished", "Jump")
			
	

func update(_delta):
	parent.handle_move_input()
	parent.get_x_input()
	parent.get_y_input()
	parent.apply_gravity(_delta)
	parent.apply_movement(_delta)
	
	if parent.is_grounded:
		if parent.x_input == 0:
			emit_signal("finished", "Idle")
	else:
		if parent.velocity.y > 0:
			emit_signal("finished", "Fall")
		if parent.velocity.y < 0:
			emit_signal("finished", "Jump")
	

func _on_Animation_finished(anim_name):
	if anim_name == "TurnBack" or anim_name == "TurnFront":
		anim.play("Walk")
	
