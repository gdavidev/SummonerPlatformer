extends Node

signal input_sequence_updated

enum {RIGHT, LEFT, DOWN, UP, AIM, ATTACK}
var input_sequence: Array = []
var input_sequence_lost: Timer

var Moves: Dictionary = {
	"Slam": [ATTACK, ATTACK, DOWN, ATTACK],
	"UpSlash": [ATTACK, ATTACK, UP, ATTACK],
	"DashRight": [RIGHT, RIGHT]
}

func _ready():
	input_sequence_lost = Timer.new()
	add_child(input_sequence_lost)
	input_sequence_lost.wait_time = 0.5
	input_sequence_lost.one_shot = true
	input_sequence_lost.connect("timeout", Callable(self, "_on_Input_Sequence_Lost_timeout"))
	

func _on_Input_Sequence_Lost_timeout():
	input_sequence = []
	emit_signal("input_sequence_updated", "timeout")
	

func _input(event):
	if event as InputEvent:
		if event.is_action_pressed("attack"):
			add_input_to_sequence(ATTACK)
			check_sequence()
			return
		if event.is_action_pressed("right"):
			add_input_to_sequence(RIGHT)
			check_sequence()
			return
		if event.is_action_pressed("left"):
			add_input_to_sequence(LEFT)
			check_sequence()
			return
		if event.is_action_pressed("down"):
			add_input_to_sequence(DOWN)
			check_sequence()
			return
		if event.is_action_pressed("up"):
			add_input_to_sequence(UP)
			check_sequence()
			return
		if event.is_action_pressed("aim"):
			add_input_to_sequence(AIM)
			check_sequence()
			return
		

func check_sequence():
	emit_signal("input_sequence_updated", input_sequence)
	input_sequence_lost.start()
	for move in Moves.keys():
		var combo: Array = Moves[move]
		var trim := input_sequence.duplicate()
		trim.invert()
		trim.resize(combo.size())
		trim.invert()
		if trim == combo:
			input_sequence = []
			input_sequence_lost.stop()
			emit_signal("input_sequence_updated", move)
			return
	

func add_input_to_sequence(input):
	input_sequence.push_back(input)
