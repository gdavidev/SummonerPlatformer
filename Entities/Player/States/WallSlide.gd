extends State

var previous_jump_count

func _ready():
	await parent.tree_entered
	parent.wall_stickness_timer.connect("timeout", Callable(self, "_on_WallSticknessTimer_timeout"))

func enter(_old_state):
	anim.play("WallSlide")
	
	previous_jump_count = parent.jump_count
	parent.jump_count = 0
	parent.velocity.x = 0.0
	parent.body.scale.x = -parent.wall_direction
	

func exit(_new_state):
	parent.wall_stickness_timer.stop()
	if _new_state != "Jump":
		parent.jump_count = previous_jump_count
	
	parent.leaving_ledge_time.start()
	parent.wall_leaving_cooldown.start()
	

func handle_input(event):
	if event as InputEvent and event.is_action_pressed("jump"):
		parent.wall_jump_lose_control_time.start()
		parent.jump(Vector2(parent.WALL_JUMP_FORCE.x * -parent.wall_direction,
						parent.WALL_JUMP_FORCE.y))
		parent.direction = parent.direction * -1
		emit_signal("finished", "Jump")
	

func update(_delta):
	parent.get_x_input()
	parent.get_y_input()
	parent.apply_movement(_delta)
	parent.handle_wall_stikness()
	parent.apply_gravity(_delta)
	parent.cap_gravity_wall_slide()
	parent.update_wall_direction()
	
	if parent.is_grounded:
		emit_signal("finished", "Idle")
	if parent.wall_direction == 0:
		emit_signal("finished", "Fall")
	if parent.velocity.y > 0:
		if parent.leaving_ledge_time.is_stopped() and parent.get_ledge():
			emit_signal("finished", "LedgeGrab")
	

func _on_Animation_finished(_anim_name):
	return
	

func _on_WallSticknessTimer_timeout():
	emit_signal("finished", "Fall")
	
