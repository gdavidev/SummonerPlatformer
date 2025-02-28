extends Sprite2D

func place(pos, _name):
	global_position = pos
	$Label.text = _name
	$Timer.start()
	

func _on_Timer_timeout():
	queue_free()
