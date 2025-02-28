extends State

func _ready():
	pass
	

func enter(_old_state):
	anim.play("WallSlide")
	parent.jump_count = 0
	parent.ledge_grab()
	parent.body.scale.x = -parent.wall_direction
	

func exit(_new_state):
	parent.leaving_ledge_time.start()
	parent.wall_leaving_cooldown.start()
	

func handle_input(event):
	if event as InputEvent and event.is_action_pressed("jump"):
		if parent.x_input == parent.wall_direction or parent.x_input == 0:
			parent.jump(parent.LEDGE_JUMP_FORCE)
			emit_signal("finished", "Jump")
		else:
			parent.wall_jump_lose_control_time.start()
			parent.jump(Vector2(parent.WALL_JUMP_FORCE.x * -parent.wall_direction,
						parent.WALL_JUMP_FORCE.y))
			emit_signal("finished", "Jump")
	
	if event.is_action_pressed("down"):
		parent.velocity = Vector2(50 * -parent.wall_direction, 100)
		emit_signal("finished", "Fall")
	

func update(_delta):
	#parent.handle_wall_stikness()
	parent.cap_gravity_wall_slide()
	parent.get_x_input()
	parent.get_y_input()
	parent.update_wall_direction()
	
	if parent.is_grounded:
		emit_signal("finished", "Idle")
	

func _on_Animation_finished(_anim_name):
	return
	

func _on_WallSticknessTimer_timeout():
	emit_signal("finished", "Fall")
