"""
to add new state just
*add instance*
await get_tree().idle_frame
update_state_map()

***Warning***
Do not queue_free() on the current state
"""

extends Node
class_name StateMachine

signal state_changed(current_state)

@export_node_path("Node") var first_state_path: NodePath
@onready var first_state: Node = get_node(first_state_path)

var state_map = {}
var state_stack = []
var previous_state = null
var current_state = null

@onready var parent = get_parent()

func _ready():
	update_state_map()
	state_stack.push_front(first_state)
	current_state = state_stack[0]
	current_state.enter("")
	

func update_state_map(_value = null):
	state_map.clear()
	for node in self.get_children():
		if node.get_children().size() > 0:
			for state_in_node in node.get_children():
				state_map[state_in_node.name] = state_in_node
				state_in_node.connect("finished", Callable(self, "_change_state"))
		else:
			state_map[node.name] = node
			node.connect("finished", Callable(self, "_change_state"))
	

func _physics_process(delta):
	current_state.update(delta)
	

func _change_state(_new_state):
	if _new_state != current_state.name:
		if _new_state == "Previous":
			_new_state = previous_state
		
		previous_state = current_state.name
		
		if state_map.get(_new_state) != null:
			current_state.exit(_new_state)
			
			state_stack[0] = state_map[_new_state]
			current_state = state_stack[0]
			
			emit_signal("state_changed", current_state)
			
			current_state.enter(previous_state)
		
	

