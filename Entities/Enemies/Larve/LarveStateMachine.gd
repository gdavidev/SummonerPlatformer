extends StateMachine

func _on_AnimationPlayer_animation_finished(anim_name):
	current_state._on_Animation_finished(anim_name)
