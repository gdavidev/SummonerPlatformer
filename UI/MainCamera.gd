extends Camera2D

const LOOK_AHEAD_FACTOR = 0.05
const PAN_FACTOR = 0.1
const SHIFT_TRANS = Tween.TRANS_SINE
const SHIFT_EASE = Tween.EASE_OUT
const SHIFT_DURATION = 1.0

var facing = 0
var target

#@onready var prev_camera_pos = get_camera_position()
@onready var prev_camera_pos = get_target_position()
@onready var tween = create_tween()

func _ready():
	Global.current_camera = self
	

func update_target(value):
	target = value
	if target != null:
		Global.player.connect("grounded_updated", Callable(self, "_on_Player_grounded_updated"))
	

func _process(_delta):
	_check_facing()
	#prev_camera_pos = get_camera_position()
	prev_camera_pos = get_target_position()
	

func _check_facing():
	#var new_facing = sign(get_camera_position().x - prev_camera_pos.x)
	var new_facing = sign(get_target_position().x - prev_camera_pos.x)
	if new_facing != 0 && facing != new_facing:
		facing = new_facing
		var target_offset = get_viewport_rect().size.x * LOOK_AHEAD_FACTOR * facing
		
		tween.tween_property(self, "position:x", target_offset, SHIFT_DURATION).set_trans(SHIFT_TRANS).set_ease(SHIFT_EASE)
		
	

func pan_camera(dir):
	var target_offset = get_viewport_rect().size.x * PAN_FACTOR * dir
	tween.tween_property(self, "position:y", target_offset, SHIFT_DURATION/4).set_trans(SHIFT_TRANS).set_ease(SHIFT_EASE)
	

func _on_Player_grounded_updated(is_grounded):
	drag_vertical_enabled = !is_grounded
