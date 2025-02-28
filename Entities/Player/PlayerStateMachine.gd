extends StateMachine

var conserved_jump_velocity = 0

func _ready():
	update_state_map()
	state_stack.push_front(first_state)
	current_state = state_stack[0]
	current_state.enter("")
	await get_tree().process_frame
	Global.scene_transition.connect("transitioning", Callable(self, "get_scene_transition"))
	parent.connect("player_damaged", Callable(self, "_on_parent_player_damaged"))
	

func _physics_process(_delta):
	if parent.x_input != parent.direction and parent.x_input != 0 and current_state is State and \
				 parent.is_grounded:
		if parent.direction == 1:
			parent.anim.play("TurnBack")
		else:
			parent.anim.play("TurnFront")
		
	print(current_state.name)

func _on_parent_player_damaged(can_damage_boost, knockback_multiplier, damager_pos):
	if not ["LedgeGrab", "Dead", "KnockBack", "DamageBoost"].has(current_state.name): #states to not apply knockback
		if ["Jump", "Fall", "DoubleJump", "Glide"].has(current_state.name): #states that can damgeboost
			if can_damage_boost and Input.is_action_pressed("jump") and parent.x_input == -parent.direction:
				parent.is_jumping = true
				parent.velocity =  Vector2(parent.DAMAGE_BOOST_FORCE.x * parent.x_input, \
											parent.DAMAGE_BOOST_FORCE.y) * knockback_multiplier
				current_state.emit_signal("finished", "DamageBoost")
			else:
				parent.apply_knockback(sign(parent.global_position.x - damager_pos.x), knockback_multiplier)
				current_state.emit_signal("finished", "KnockBack")
		else:
			parent.apply_knockback(sign(parent.global_position.x - damager_pos.x), knockback_multiplier)
			current_state.emit_signal("finished", "KnockBack")
	

func get_scene_transition(value):
	if value == true:
		current_state.emit_signal("finished", "SceneTransition")
	else:
		current_state.emit_signal("finished", "Idle")


func _input(event):
	current_state.handle_input(event)
	
	#if event as InputEvent:
		#if !["LedgeGrab", "WallSlide", "SceneTransition"].has(current_state) and \
												#!current_state as CombatAction:
			#if event.is_action_pressed("attack"):
				#current_state.emit_signal("finished", "CombatHandler")
	

func _on_AnimationPlayer_animation_finished(anim_name):
	current_state._on_Animation_finished(anim_name)
