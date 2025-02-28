extends State

@export var damage: float

var attack_type: String = ""
var last_attack_type: String = ""
var attack_number: int = 0
var attack_cicle: int = 1 #when the combo cycles

var actions = {}
var last_action = null

@onready var combat_handler = self
@onready var combo_lost_timer = $"ComboLostTimer"
@onready var action_pressed_buffer = $"ActionPressedBuffer"

func _ready():
	for action in get_parent().get_children():
		if action != self:
			actions[action.name] = action
	

func enter(old_state):
	combo_lost_timer.start()
	
	if parent.is_grounded:
		attack_type = "G"
		attack_cicle = 2
	else:
		attack_type = "A"
		attack_cicle = 1
	
	if action_pressed_buffer.is_stopped():
		if actions.has(old_state):
			emit_signal("finished", "Idle")
		else:
			execute_attack()
	else:
		execute_attack()
	

func execute_attack():
	if last_attack_type != attack_type:
		last_attack_type = attack_type
		attack_number = 0
	for i in actions.keys():
		if i.begins_with(attack_type + str(attack_number)):
			attack_number = (attack_number + 1) % attack_cicle
			combo_lost_timer.stop()
			action_pressed_buffer.stop()
			parent.update_facing_direction()
			get_parent().scale.x = parent.direction
			emit_signal("finished", i)
			break
	

func exit(_new_state):
	return
	

func handle_input(_event):
	return
	

func update(_delta):
	return
	

func _on_Animation_finished(_anim_name):
	return
	

func _on_ComboLostTimer_timeout():
	attack_number = 0
	
