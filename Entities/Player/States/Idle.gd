extends State

func enter(old_state):
	if old_state == "Walk" or old_state == "Fall":
		anim.play("Stop")
		anim.queue("Idle")
	else:
		anim.play("Idle")
	

func exit(_new_state):
	#Global.current_camera.pan_camera(0)
	parent.pan_camera_delay.stop()
	anim.clear_queue()
	

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
				else:
					if parent.check_colliding_raycasts(parent.ceilling_rays) == false:
						parent.jump()
						emit_signal("finished", "Jump")
		

func update(_delta):
	parent.handle_move_input()
	parent.get_x_input()
	parent.get_y_input()
	parent.apply_gravity(_delta)
	parent.apply_movement(_delta)
	
	if parent.y_input != 0:
		if parent.pan_camera_delay.is_stopped():
			parent.pan_camera_delay.start()
	else:
		Global.current_camera.pan_camera(0)
	
	if parent.is_grounded:
		if parent.x_input != 0:
			emit_signal("finished", "Walk")
	else:
		if parent.velocity.y > 0:
			emit_signal("finished", "Fall")
		if parent.velocity.y < 0:
			emit_signal("finished", "Jump")
	

func _on_Animation_finished(anim_name):
	if anim_name == "TurnBack" or anim_name == "TurnFront":
		anim.play("Idle")
	

func _on_PanCameraDelay_timeout():
	Global.current_camera.pan_camera(parent.y_input)
