extends CanvasLayer

signal transition(value: bool)
var transitioning: bool = false

@onready var anim = $AnimationPlayer

func _ready():
	$Panel.modulate.a = 0.0


func fade_in():
	anim.play("Fade-In")
	transitioning = true
	emit_signal("transitioning", true)
	

func fade_out():
	anim.play("Fade-Out")
	transitioning = false
	emit_signal("transitioning", false)
	
